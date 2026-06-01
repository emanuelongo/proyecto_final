import '../app_database.dart' as db;

class InsumoDao {
  InsumoDao(this._db);

  final db.AppDatabase _db;

  Stream<List<db.Insumo>> watchAll() {
    return _db.select(_db.insumos).watch();
  }

  Future<db.Insumo?> getById(String id) {
    return (_db.select(_db.insumos)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsert(db.Insumo insumo) async {
    await _db.into(_db.insumos).insertOnConflictUpdate(insumo);
  }

  Future<void> deleteById(String id) async {
    await (_db.delete(_db.insumos)..where((tbl) => tbl.id.equals(id))).go();
  }

  Stream<List<db.Insumo>> watchByStatus(String status) {
    return (_db.select(_db.insumos)..where((tbl) => tbl.status.equals(status))).watch();
  }

  Future<List<db.Insumo>> getPendingSync() {
    return (_db.select(_db.insumos)..where((tbl) => tbl.syncStatus.equals('pendingSync'))).get();
  }

  Future<List<db.Insumo>> getAll() {
    return _db.select(_db.insumos).get();
  }
}
