import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

LazyDatabase openDatabase() {
  return LazyDatabase(() async {
    // driftDatabase se encarga de abrir IndexedDB de forma segura en la Web
    final connection = driftDatabase(
      name: 'app_database',
    );
    return connection;
  });
}