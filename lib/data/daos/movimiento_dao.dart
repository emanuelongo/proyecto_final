import '../app_database.dart' as db;

class MovimientoDao {
  MovimientoDao(this._db);

  final db.AppDatabase _db;

  Stream<List<db.Movimiento>> watchAll() {
    return _db.select(_db.movimientos).watch();
  }

  Stream<List<db.Movimiento>> watchByInsumo(String insumoId) {
    return (_db.select(_db.movimientos)..where((tbl) => tbl.insumoId.equals(insumoId))).watch();
  }

  Future<void> upsert(db.Movimiento movimiento) async {
    await _db.into(_db.movimientos).insertOnConflictUpdate(movimiento);
  }

  Future<List<db.Movimiento>> getPendingSync() {
    return (_db.select(_db.movimientos)..where((tbl) => tbl.syncStatus.equals('pendingSync'))).get();
  }
}
