import 'package:drift/drift.dart';

import '../app_database.dart';

class InsumoDao {
  InsumoDao(this._db);

  final AppDatabase _db;

  Stream<List<Insumo>> watchAll() {
    return _db.select(_db.insumos).watch();
  }

  Future<Insumo?> getById(String id) {
    return (_db.select(_db.insumos)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsert(Insumo insumo) async {
    await _db.into(_db.insumos).insertOnConflictUpdate(insumo);
  }

  Future<void> deleteById(String id) async {
    await (_db.delete(_db.insumos)..where((tbl) => tbl.id.equals(id))).go();
  }

  Stream<List<Insumo>> watchByStatus(String status) {
    return (_db.select(_db.insumos)..where((tbl) => tbl.status.equals(status))).watch();
  }

  Future<List<Insumo>> getPendingSync() {
    return (_db.select(_db.insumos)..where((tbl) => tbl.syncStatus.equals('pendingSync'))).get();
  }
}
