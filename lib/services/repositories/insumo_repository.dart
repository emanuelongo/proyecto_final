import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/app_database.dart' as db;
import '../../data/daos/insumo_dao.dart';
import '../../data/mappers.dart';
import '../../models/insumo.dart';
import '../../models/enums.dart';
import '../inventory_service.dart';

class InsumoRepository {
  InsumoRepository(
    this._db, {
    FirebaseFirestore? firestore,
    InventoryService? inventoryService,
  })  : _dao = InsumoDao(_db),
        _collection = (firestore ?? FirebaseFirestore.instance).collection('insumos'),
        _inventoryService = inventoryService;

  final db.AppDatabase _db;
  final InsumoDao _dao;
  final CollectionReference<Map<String, dynamic>> _collection;
  final InventoryService? _inventoryService;

  Stream<List<Insumo>> watchLocal() {
    return _dao.watchAll().map((rows) => rows.map(insumoFromDb).toList());
  }

  /// Lectura en vivo desde Firestore (inventario en web y movil).
  Stream<List<Insumo>> watchRemote() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = data['id'] ?? doc.id;
        return Insumo.fromMap(data);
      }).toList();
    });
  }

  Future<Insumo?> getById(String id) async {
    final row = await _dao.getById(id);
    if (row == null) {
      return null;
    }
    return insumoFromDb(row);
  }

  Future<List<Insumo>> getAll() async {
    final rows = await _dao.getAll();
    return rows.map(insumoFromDb).toList();
  }

  Future<void> upsertLocal(Insumo insumo, {bool markPending = false}) async {
    final value = markPending ? insumo.copyWith(syncStatus: SyncStatus.pendingSync) : insumo;
    await _dao.upsert(insumoToDb(value));
    if (_inventoryService != null) {
      await _inventoryService.ensureLowStockAlert(value);
    }
  }

  Future<void> pullRemote() async {
    final snapshot = await _collection.get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      data['id'] = data['id'] ?? doc.id;
      final insumo = Insumo.fromMap(data);
      await _dao.upsert(insumoToDb(insumo));
      if (_inventoryService != null) {
        await _inventoryService.ensureLowStockAlert(insumo);
      }
    }
  }

  Future<void> pushPending() async {
    print('=== InsumoRepository.pushPending ===');
    final pending = await _dao.getPendingSync();
    print('Insumos pendientes para sincronizar: ${pending.length}');
    for (final row in pending) {
      final model = insumoFromDb(row);
      print('Sincronizando insumo: ${model.id}, totalQuantity: ${model.totalQuantity}');
      try {
        await _collection.doc(model.id).set(model.toMap());
        print('Insumo ${model.id} sincronizado exitosamente');
        await _dao.upsert(insumoToDb(model.copyWith(syncStatus: SyncStatus.synced)));
      } catch (e) {
        print('Error al sincronizar insumo ${model.id}: $e');
        await _dao.upsert(insumoToDb(model.copyWith(syncStatus: SyncStatus.failedSync)));
      }
    }
  }
}
