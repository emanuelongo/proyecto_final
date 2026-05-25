import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? dateFromValue(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

String? dateToString(DateTime? value) {
  return value?.toIso8601String();
}

int intFromValue(dynamic value) {
  if (value == null) {
    return 0;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

T? enumFromString<T extends Enum>(List<T> values, dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is T) {
    return value;
  }
  if (value is String) {
    for (final entry in values) {
      if (entry.name == value) {
        return entry;
      }
    }
  }
  return null;
}
