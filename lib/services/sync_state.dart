import 'package:flutter/foundation.dart';

class SyncState {
  final ValueNotifier<DateTime?> lastSyncAt = ValueNotifier<DateTime?>(null);
  final ValueNotifier<String?> lastSyncError = ValueNotifier<String?>(null);

  void markSuccess() {
    lastSyncAt.value = DateTime.now();
    lastSyncError.value = null;
  }

  void markError(String message) {
    lastSyncError.value = message;
  }
}
