import '../models/enums.dart';
import '../models/insumo.dart';
import '../models/lote.dart';
import '../models/movimiento.dart';
import '../services/rules_service.dart';
import 'repositories/insumo_repository.dart';
import 'repositories/lote_repository.dart';
import 'repositories/movimiento_repository.dart';

class MovementService {
  MovementService({
    required InsumoRepository insumoRepository,
    required LoteRepository loteRepository,
    required MovimientoRepository movimientoRepository,
    RulesService? rulesService,
  })  : _insumoRepository = insumoRepository,
        _loteRepository = loteRepository,
        _movimientoRepository = movimientoRepository,
        _rulesService = rulesService ?? const RulesService();

  final InsumoRepository _insumoRepository;
  final LoteRepository _loteRepository;
  final MovimientoRepository _movimientoRepository;
  final RulesService _rulesService;

  Future<void> registerInbound({
    required Insumo insumo,
    required int quantity,
    required String userId,
    DateTime? expirationDate,
  }) async {
    if (quantity <= 0) {
      throw StateError('Cantidad invalida.');
    }

    final lote = Lote(
      id: '${DateTime.now().millisecondsSinceEpoch}-in',
      insumoId: insumo.id,
      quantity: quantity,
      expirationDate: expirationDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingSync,
    );
    await _loteRepository.upsertLocal(lote, markPending: true);

    final movimiento = Movimiento(
      id: '${DateTime.now().millisecondsSinceEpoch}-${lote.id}',
      insumoId: insumo.id,
      loteId: lote.id,
      type: MovementType.inbound,
      quantity: quantity,
      createdBy: userId,
      createdAt: DateTime.now(),
      syncStatus: SyncStatus.pendingSync,
    );
    await _movimientoRepository.upsertLocal(movimiento, markPending: true);

    final updatedInsumo = insumo.copyWith(
      totalQuantity: insumo.totalQuantity + quantity,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingSync,
    );
    await _insumoRepository.upsertLocal(updatedInsumo, markPending: true);
  }

  Future<void> registerOutbound({
    required Insumo insumo,
    required int quantity,
    required String userId,
  }) async {
    print('=== MovementService.registerOutbound ===');
    print('Insumo: ${insumo.name} (${insumo.id}), quantity: $quantity, current total: ${insumo.totalQuantity}');

    final lotes = await _loteRepository.getByInsumo(insumo.id);
    print('Lotes encontrados: ${lotes.length}');

    final availableLotes = lotes.where((lote) => !_rulesService.isLoteExpired(lote) && lote.quantity > 0).toList();
    print('Lotes disponibles (no expirados y >0): ${availableLotes.length}');

    final availableQty = availableLotes.fold<int>(0, (sum, lote) => sum + lote.quantity.toInt());
    print('Cantidad disponible: $availableQty');

    if (!_rulesService.validateStock(availableQty, quantity)) {
      throw StateError('Stock insuficiente en lotes vigentes. Disponible: $availableQty, solicitado: $quantity');
    }

    var remaining = quantity;
    final sorted = List<Lote>.from(availableLotes)
      ..sort((a, b) {
        final aDate = a.expirationDate;
        final bDate = b.expirationDate;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return aDate.compareTo(bDate);
      });

    print('Lotes ordenados para usar: ${sorted.length}');

    for (final lote in sorted) {
      if (remaining <= 0) {
        break;
      }
      print('Procesando lote: ${lote.id}, cantidad: ${lote.quantity}');

      final used = remaining > lote.quantity ? lote.quantity : remaining;
      remaining -= used;

      print('Usando $used de lote ${lote.id}, remaining: $remaining');

      final updatedLote = lote.copyWith(
        quantity: lote.quantity - used,
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pendingSync,
      );
      await _loteRepository.upsertLocal(updatedLote, markPending: true);
      print('Lote actualizado: ${lote.id}, nueva cantidad: ${updatedLote.quantity}');

      final movimiento = Movimiento(
        id: '${DateTime.now().millisecondsSinceEpoch}-${lote.id}',
        insumoId: insumo.id,
        loteId: lote.id,
        type: MovementType.outbound,
        quantity: used,
        createdBy: userId,
        createdAt: DateTime.now(),
        syncStatus: SyncStatus.pendingSync,
      );
      await _movimientoRepository.upsertLocal(movimiento, markPending: true);
      print('Movimiento registrado: ${movimiento.id}');
    }

    final updatedInsumo = insumo.copyWith(
      totalQuantity: insumo.totalQuantity - quantity,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingSync,
    );
    await _insumoRepository.upsertLocal(updatedInsumo, markPending: true);
    print('Insumo actualizado: ${insumo.name}, nuevo total: ${updatedInsumo.totalQuantity}');
  }
}
