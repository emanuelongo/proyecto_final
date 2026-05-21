import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:proyecto_final/models/enums.dart';
import 'package:proyecto_final/widgets/empty_state.dart';
import 'package:proyecto_final/widgets/error_state.dart';
import 'package:proyecto_final/widgets/loading_state.dart';
import 'package:proyecto_final/widgets/sync_status_chip.dart';

void main() {
  testWidgets('EmptyState shows message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(message: 'Sin datos'),
        ),
      ),
    );

    expect(find.text('Sin datos'), findsOneWidget);
  });

  testWidgets('LoadingState shows progress', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingState(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ErrorState shows retry button when provided', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorState(
            message: 'Error',
            onRetry: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Reintentar'), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    expect(tapped, isTrue);
  });

  testWidgets('SyncStatusChip pending shows label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SyncStatusChip(status: SyncStatus.pendingSync),
        ),
      ),
    );

    expect(find.text('Pendiente'), findsOneWidget);
  });
}
