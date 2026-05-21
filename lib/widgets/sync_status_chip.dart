import 'package:flutter/material.dart';

import '../models/enums.dart';
import 'status_chip.dart';

class SyncStatusChip extends StatelessWidget {
  const SyncStatusChip({super.key, required this.status});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case SyncStatus.synced:
        return const StatusChip(label: 'Sincronizado', color: Colors.green);
      case SyncStatus.pendingSync:
        return const StatusChip(label: 'Pendiente', color: Colors.orange);
      case SyncStatus.failedSync:
        return const StatusChip(label: 'Error', color: Colors.red);
    }
  }
}
