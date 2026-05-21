import '../app_database.dart' as db;

class LoteDao {
  LoteDao(this._db);

  final db.AppDatabase _db;

  Stream<List<db.Lote>> watchByInsumo(String insumoId) {
    return (_db.select(_db.lotes)..where((tbl) => tbl.insumoId.equals(insumoId))).watch();
  }

  Future<List<db.Lote>> getByInsumo(String insumoId) {
    return (_db.select(_db.lotes)..where((tbl) => tbl.insumoId.equals(insumoId))).get();
  }

  Future<db.Lote?> getById(String id) {
    return (_db.select(_db.lotes)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsert(db.Lote lote) async {
    await _db.into(_db.lotes).insertOnConflictUpdate(lote);
  }

  Future<void> deleteById(String id) async {
    await (_db.delete(_db.lotes)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<List<db.Lote>> getPendingSync() {
    return (_db.select(_db.lotes)..where((tbl) => tbl.syncStatus.equals('pendingSync'))).get();
  }
}
