DateTime? dateFromValue(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

String? dateToString(DateTime? value) {
  return value?.toIso8601String();
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
