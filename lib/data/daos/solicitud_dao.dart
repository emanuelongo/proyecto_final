import 'package:drift/drift.dart';

import '../app_database.dart';

class SolicitudDao {
  SolicitudDao(this._db);

  final AppDatabase _db;

  Stream<List<Solicitud>> watchAll() {
    return _db.select(_db.solicitudes).watch();
  }

  Stream<List<Solicitud>> watchByRequester(String userId) {
    return (_db.select(_db.solicitudes)..where((tbl) => tbl.requestedBy.equals(userId))).watch();
  }

  Stream<List<Solicitud>> watchByStatus(String status) {
    return (_db.select(_db.solicitudes)..where((tbl) => tbl.status.equals(status))).watch();
  }

  Future<Solicitud?> getById(String id) {
    return (_db.select(_db.solicitudes)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsert(Solicitud solicitud) async {
    await _db.into(_db.solicitudes).insertOnConflictUpdate(solicitud);
  }

  Future<List<Solicitud>> getPendingSync() {
    return (_db.select(_db.solicitudes)..where((tbl) => tbl.syncStatus.equals('pendingSync'))).get();
  }
}
