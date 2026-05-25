import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/app_database.dart' as db;
import '../../data/daos/solicitud_dao.dart';
import '../../data/mappers.dart';
import '../../models/enums.dart';
import '../../models/solicitud.dart';

class SolicitudRepository {
  SolicitudRepository(this._db, {FirebaseFirestore? firestore})
      : _dao = SolicitudDao(_db),
        _collection = (firestore ?? FirebaseFirestore.instance).collection('solicitudes');

  final db.AppDatabase _db;
  final SolicitudDao _dao;
  final CollectionReference<Map<String, dynamic>> _collection;

  Stream<List<Solicitud>> watchLocal() {
    return _dao.watchAll().map((rows) => rows.map(solicitudFromDb).toList());
  }

  Stream<List<Solicitud>> watchByRequester(String userId) {
    return _dao.watchByRequester(userId).map((rows) => rows.map(solicitudFromDb).toList());
  }

  Future<void> upsertLocal(Solicitud solicitud, {bool markPending = false}) async {
    final value = markPending ? solicitud.copyWith(syncStatus: SyncStatus.pendingSync) : solicitud;
    await _dao.upsert(solicitudToDb(value));
  }

  Future<void> pullRemote() async {
    final snapshot = await _collection.get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      data['id'] = data['id'] ?? doc.id;
      final solicitud = Solicitud.fromMap(data);
      await _dao.upsert(solicitudToDb(solicitud));
    }
  }

  Future<void> pushPending() async {
    final pending = await _dao.getPendingSync();
    for (final row in pending) {
      final model = solicitudFromDb(row);
      try {
        await _collection.doc(model.id).set(model.toMap());
        await _dao.upsert(solicitudToDb(model.copyWith(syncStatus: SyncStatus.synced)));
      } catch (_) {
        await _dao.upsert(solicitudToDb(model.copyWith(syncStatus: SyncStatus.failedSync)));
      }
    }
  }
}
