import 'package:flutter_test/flutter_test.dart';

import 'package:proyecto_final/models/enums.dart';
import 'package:proyecto_final/models/lote.dart';
import 'package:proyecto_final/services/rules_service.dart';

void main() {
  group('RulesService', () {
    final service = RulesService();

    test('validateStock true when available', () {
      expect(service.validateStock(10, 3), isTrue);
    });

    test('validateStock false when exceeds available', () {
      expect(service.validateStock(5, 6), isFalse);
    });

    test('canTransitionSolicitud requested -> approved', () {
      expect(
        service.canTransitionSolicitud(SolicitudStatus.requested, SolicitudStatus.approved),
        isTrue,
      );
    });

    test('cannot transition approved -> requested', () {
      expect(
        service.canTransitionSolicitud(SolicitudStatus.approved, SolicitudStatus.requested),
        isFalse,
      );
    });

    test('computeInventoryStatus low stock', () {
      final status = service.computeInventoryStatus(
        totalQty: 2,
        hasExpired: false,
        lowStockThreshold: 5,
      );
      expect(status, InventoryStatus.lowStock);
    });

    test('isLoteExpired detects past expiration', () {
      final lote = Lote(
        id: 'l1',
        insumoId: 'i1',
        quantity: 1,
        expirationDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(service.isLoteExpired(lote), isTrue);
    });

    test('applyMovement outbound decreases quantity', () {
      final result = service.applyMovement(
        currentQty: 10,
        type: MovementType.outbound,
        quantity: 4,
      );
      expect(result, 6);
    });
  });
}
