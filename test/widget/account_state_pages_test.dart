import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:proyecto_final/pages/blocked_page.dart';
import 'package:proyecto_final/pages/pending_approval_page.dart';

void main() {
  testWidgets('PendingApprovalPage shows waiting message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PendingApprovalPage(),
      ),
    );

    expect(find.text('Cuenta pendiente de aprobacion'), findsOneWidget);
  });

  testWidgets('BlockedPage shows blocked message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BlockedPage(),
      ),
    );

    expect(find.text('Acceso bloqueado'), findsOneWidget);
  });
}
