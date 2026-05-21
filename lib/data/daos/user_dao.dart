import 'package:drift/drift.dart';

import '../app_database.dart';

class UserDao {
  UserDao(this._db);

  final AppDatabase _db;

  Future<void> upsert(User user) async {
    await _db.into(_db.users).insertOnConflictUpdate(user);
  }

  Future<User?> getById(String id) {
    return (_db.select(_db.users)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Stream<User?> watchById(String id) {
    return (_db.select(_db.users)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<void> deleteById(String id) async {
    await (_db.delete(_db.users)..where((tbl) => tbl.id.equals(id))).go();
  }
}
