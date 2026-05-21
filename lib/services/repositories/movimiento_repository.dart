import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/app_database.dart';
import '../../data/daos/movimiento_dao.dart';
import '../../data/mappers.dart';
import '../../models/enums.dart';
import '../../models/movimiento.dart';

class MovimientoRepository {
  MovimientoRepository(this._db, {FirebaseFirestore? firestore})
      : _dao = MovimientoDao(_db),
        _collection = (firestore ?? FirebaseFirestore.instance).collection('movimientos');

  final AppDatabase _db;
  final MovimientoDao _dao;
  final CollectionReference<Map<String, dynamic>> _collection;

  Stream<List<Movimiento>> watchLocalByInsumo(String insumoId) {
    return _dao.watchByInsumo(insumoId).map((rows) => rows.map(movimientoFromDb).toList());
  }

  Future<void> upsertLocal(Movimiento movimiento, {bool markPending = false}) async {
    final value = markPending ? movimiento.copyWith(syncStatus: SyncStatus.pendingSync) : movimiento;
    await _dao.upsert(movimientoToDb(value));
  }

  Future<void> pullRemote() async {
    final snapshot = await _collection.get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      data['id'] = data['id'] ?? doc.id;
      final movimiento = Movimiento.fromMap(data);
      await _dao.upsert(movimientoToDb(movimiento));
    }
  }

  Future<void> pushPending() async {
    final pending = await _dao.getPendingSync();
    for (final row in pending) {
      final model = movimientoFromDb(row);
      try {
        await _collection.doc(model.id).set(model.toMap());
        await _dao.upsert(movimientoToDb(model.copyWith(syncStatus: SyncStatus.synced)));
      } catch (_) {
        await _dao.upsert(movimientoToDb(model.copyWith(syncStatus: SyncStatus.failedSync)));
      }
    }
  }
}
