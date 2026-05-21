import 'package:drift/drift.dart';

import '../app_database.dart';

class MovimientoDao {
  MovimientoDao(this._db);

  final AppDatabase _db;

  Stream<List<Movimiento>> watchAll() {
    return _db.select(_db.movimientos).watch();
  }

  Stream<List<Movimiento>> watchByInsumo(String insumoId) {
    return (_db.select(_db.movimientos)..where((tbl) => tbl.insumoId.equals(insumoId))).watch();
  }

  Future<void> upsert(Movimiento movimiento) async {
    await _db.into(_db.movimientos).insertOnConflictUpdate(movimiento);
  }

  Future<List<Movimiento>> getPendingSync() {
    return (_db.select(_db.movimientos)..where((tbl) => tbl.syncStatus.equals('pendingSync'))).get();
  }
}
