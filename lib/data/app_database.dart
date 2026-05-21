import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get role => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Insumos extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get unit => text()();
  IntColumn get totalQuantity => integer()();
  TextColumn get status => text()();
  IntColumn get lowStockThreshold => integer()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get syncStatus => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Lotes extends Table {
  TextColumn get id => text()();
  TextColumn get insumoId => text()();
  IntColumn get quantity => integer()();
  DateTimeColumn get expirationDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get syncStatus => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Movimientos extends Table {
  TextColumn get id => text()();
  TextColumn get insumoId => text()();
  TextColumn get loteId => text().nullable()();
  TextColumn get type => text()();
  IntColumn get quantity => integer()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  TextColumn get syncStatus => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Solicitudes extends Table {
  TextColumn get id => text()();
  TextColumn get insumoId => text()();
  TextColumn get requestedBy => text()();
  IntColumn get quantity => integer()();
  TextColumn get status => text()();
  TextColumn get reviewerId => text().nullable()();
  TextColumn get rejectionReason => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get syncStatus => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Alertas extends Table {
  TextColumn get id => text()();
  TextColumn get insumoId => text()();
  TextColumn get type => text()();
  TextColumn get message => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  BoolColumn get resolved => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(path.join(dir.path, 'app_database.sqlite'));
    return NativeDatabase(file);
  });
}

@DriftDatabase(tables: [Users, Insumos, Lotes, Movimientos, Solicitudes, Alertas])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}
