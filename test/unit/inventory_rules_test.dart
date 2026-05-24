import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final/models/enums.dart';
import 'package:proyecto_final/models/lote.dart';
import 'package:proyecto_final/services/rules_service.dart';

void main() {
  late RulesService rulesService;

  setUp(() {
    rulesService = const RulesService();
  });

  group('Reglas de inventario y lotes', () {
    test('un lote vencido no puede usarse', () {
      final lote = Lote(
        id: 'lote_vencido',
        insumoId: 'insumo_1',
        quantity: 10,
        expirationDate: DateTime(2026, 5, 1),
      );

      final result = rulesService.canUseLote(
        lote,
        at: DateTime(2026, 5, 2),
      );

      expect(result, isFalse);
    });

    test('un lote no vencido si puede usarse', () {
      final lote = Lote(
        id: 'lote_disponible',
        insumoId: 'insumo_1',
        quantity: 10,
        expirationDate: DateTime(2026, 5, 30),
      );

      final result = rulesService.canUseLote(
        lote,
        at: DateTime(2026, 5, 2),
      );

      expect(result, isTrue);
    });

    test('no se puede solicitar mas cantidad de la disponible', () {
      final result = rulesService.validateStock(
        5, // disponible
        8, // solicitado
      );

      expect(result, isFalse);
    });

    test('stock bajo genera condicion de alerta', () {
      final result = rulesService.shouldTriggerLowStock(
        3,
        threshold: 5,
      );

      expect(result, isTrue);
    });

    test('cantidad cero queda como agotado', () {
      final status = rulesService.computeInventoryStatus(
        totalQty: 0,
        hasExpired: false,
        lowStockThreshold: 5,
      );

      expect(status, InventoryStatus.outOfStock);
    });

    test('cantidad baja queda como lowStock', () {
      final status = rulesService.computeInventoryStatus(
        totalQty: 3,
        hasExpired: false,
        lowStockThreshold: 5,
      );

      expect(status, InventoryStatus.lowStock);
    });
  });
}