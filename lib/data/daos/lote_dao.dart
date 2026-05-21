import '../app_database.dart';

class LoteDao {
  LoteDao(this._db);

  final AppDatabase _db;

  Stream<List<Lote>> watchByInsumo(String insumoId) {
    return (_db.select(_db.lotes)..where((tbl) => tbl.insumoId.equals(insumoId))).watch();
  }

  Future<List<Lote>> getByInsumo(String insumoId) {
    return (_db.select(_db.lotes)..where((tbl) => tbl.insumoId.equals(insumoId))).get();
  }

  Future<Lote?> getById(String id) {
    return (_db.select(_db.lotes)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsert(Lote lote) async {
    await _db.into(_db.lotes).insertOnConflictUpdate(lote);
  }

  Future<void> deleteById(String id) async {
    await (_db.delete(_db.lotes)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<List<Lote>> getPendingSync() {
    return (_db.select(_db.lotes)..where((tbl) => tbl.syncStatus.equals('pendingSync'))).get();
  }
}
