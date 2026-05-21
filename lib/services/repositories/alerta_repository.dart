import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/app_database.dart';
import '../../data/daos/alerta_dao.dart';
import '../../data/mappers.dart';
import '../../models/alerta.dart';
import '../../models/enums.dart';

class AlertaRepository {
  AlertaRepository(this._db, {FirebaseFirestore? firestore})
      : _dao = AlertaDao(_db),
        _collection = (firestore ?? FirebaseFirestore.instance).collection('alertas');

  final AppDatabase _db;
  final AlertaDao _dao;
  final CollectionReference<Map<String, dynamic>> _collection;

  Stream<List<Alerta>> watchLocal() {
    return _dao.watchAll().map((rows) => rows.map(alertaFromDb).toList());
  }

  Stream<List<Alerta>> watchLocalByInsumo(String insumoId) {
    return _dao.watchByInsumo(insumoId).map((rows) => rows.map(alertaFromDb).toList());
  }

  Future<Alerta?> getOpenByInsumoAndType(String insumoId, AlertType type) {
    return _dao.getOpenByInsumoAndType(insumoId, type.name);
  }

  Future<void> upsertLocal(Alerta alerta, {bool markPending = false}) async {
    final value = markPending ? alerta.copyWith(syncStatus: SyncStatus.pendingSync) : alerta;
    await _dao.upsert(alertaToDb(value));
  }

  Future<void> pullRemote() async {
    final snapshot = await _collection.get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      data['id'] = data['id'] ?? doc.id;
      final alerta = Alerta.fromMap(data);
      await _dao.upsert(alertaToDb(alerta));
    }
  }

  Future<void> pushPending() async {
    final pending = await _dao.getPendingSync();
    for (final row in pending) {
      final model = alertaFromDb(row);
      try {
        await _collection.doc(model.id).set(model.toMap());
        await _dao.upsert(alertaToDb(model.copyWith(syncStatus: SyncStatus.synced)));
      } catch (_) {
        await _dao.upsert(alertaToDb(model.copyWith(syncStatus: SyncStatus.failedSync)));
      }
    }
  }
}
