import 'package:drift/drift.dart';
import 'package:drift/web.dart';

LazyDatabase openDatabase() {
  return LazyDatabase(() async {
    return WebDatabase('app_database');
  });
}
