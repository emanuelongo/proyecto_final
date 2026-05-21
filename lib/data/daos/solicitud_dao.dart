import '../app_database.dart' as db;

class SolicitudDao {
  SolicitudDao(this._db);

  final db.AppDatabase _db;

  Stream<List<db.Solicitude>> watchAll() {
    return _db.select(_db.solicitudes).watch();
  }

  Stream<List<db.Solicitude>> watchByRequester(String userId) {
    return (_db.select(_db.solicitudes)..where((tbl) => tbl.requestedBy.equals(userId))).watch();
  }

  Stream<List<db.Solicitude>> watchByStatus(String status) {
    return (_db.select(_db.solicitudes)..where((tbl) => tbl.status.equals(status))).watch();
  }

  Future<db.Solicitude?> getById(String id) {
    return (_db.select(_db.solicitudes)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsert(db.Solicitude solicitud) async {
    await _db.into(_db.solicitudes).insertOnConflictUpdate(solicitud);
  }

  Future<List<db.Solicitude>> getPendingSync() {
    return (_db.select(_db.solicitudes)..where((tbl) => tbl.syncStatus.equals('pendingSync'))).get();
  }
}
