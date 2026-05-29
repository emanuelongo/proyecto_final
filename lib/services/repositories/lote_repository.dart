import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/app_database.dart' as db;
import '../../data/daos/lote_dao.dart';
import '../../data/mappers.dart';
import '../../models/enums.dart';
import '../../models/lote.dart';

class LoteRepository {
  LoteRepository(this._db, {FirebaseFirestore? firestore})
      : _dao = LoteDao(_db),
        _collection = (firestore ?? FirebaseFirestore.instance).collection('lotes');

  final db.AppDatabase _db;
  final LoteDao _dao;
  final CollectionReference<Map<String, dynamic>> _collection;

  Stream<List<Lote>> watchLocalByInsumo(String insumoId) {
    return _dao.watchByInsumo(insumoId).map((rows) => rows.map(loteFromDb).toList());
  }

  Stream<List<Lote>> watchRemoteByInsumo(String insumoId) {
    return _collection.where('insumoId', isEqualTo: insumoId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = data['id'] ?? doc.id;
        return Lote.fromMap(data);
      }).toList();
    });
  }

  Future<List<Lote>> getByInsumo(String insumoId) {
    return _dao.getByInsumo(insumoId).then((rows) => rows.map(loteFromDb).toList());
  }

  Future<void> upsertLocal(Lote lote, {bool markPending = false}) async {
    final value = markPending ? lote.copyWith(syncStatus: SyncStatus.pendingSync) : lote;
    await _dao.upsert(loteToDb(value));
  }

  Future<void> pullRemote() async {
    final snapshot = await _collection.get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      data['id'] = data['id'] ?? doc.id;
      final lote = Lote.fromMap(data);
      await _dao.upsert(loteToDb(lote));
    }
  }

  Future<void> pushPending() async {
    final pending = await _dao.getPendingSync();
    for (final row in pending) {
      final model = loteFromDb(row);
      try {
        await _collection.doc(model.id).set(model.toMap());
        await _dao.upsert(loteToDb(model.copyWith(syncStatus: SyncStatus.synced)));
      } catch (_) {
        await _dao.upsert(loteToDb(model.copyWith(syncStatus: SyncStatus.failedSync)));
      }
    }
  }
}
