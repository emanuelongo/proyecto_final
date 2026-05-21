import 'package:drift/drift.dart';

import '../app_database.dart';

class AlertaDao {
  AlertaDao(this._db);

  final AppDatabase _db;

  Stream<List<Alerta>> watchAll() {
    return _db.select(_db.alertas).watch();
  }

  Stream<List<Alerta>> watchByInsumo(String insumoId) {
    return (_db.select(_db.alertas)..where((tbl) => tbl.insumoId.equals(insumoId))).watch();
  }

  Future<Alerta?> getOpenByInsumoAndType(String insumoId, String type) {
    return (_db.select(_db.alertas)
          ..where((tbl) => tbl.insumoId.equals(insumoId) & tbl.type.equals(type))
          ..where((tbl) => tbl.resolved.equals(false)))
        .getSingleOrNull();
  }

  Future<void> upsert(Alerta alerta) async {
    await _db.into(_db.alertas).insertOnConflictUpdate(alerta);
  }

  Future<void> resolveAlert(String id, {String syncStatus = 'pendingSync'}) async {
    await (_db.update(_db.alertas)..where((tbl) => tbl.id.equals(id))).write(
      AlertasCompanion(
        resolved: const Value(true),
        syncStatus: Value(syncStatus),
      ),
    );
  }

  Future<List<Alerta>> getPendingSync() {
    return (_db.select(_db.alertas)..where((tbl) => tbl.syncStatus.equals('pendingSync'))).get();
  }
}
