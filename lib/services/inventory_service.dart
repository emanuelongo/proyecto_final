import '../models/alerta.dart';
import '../models/enums.dart';
import '../models/insumo.dart';
import '../services/rules_service.dart';
import 'repositories/alerta_repository.dart';

class InventoryService {
  InventoryService({
    required AlertaRepository alertaRepository,
    RulesService? rulesService,
  })  : _alertaRepository = alertaRepository,
        _rulesService = rulesService ?? const RulesService();

  final AlertaRepository _alertaRepository;
  final RulesService _rulesService;

  Future<void> ensureLowStockAlert(Insumo insumo) async {
    final shouldAlert = _rulesService.shouldTriggerLowStock(
      insumo.totalQuantity,
      threshold: insumo.lowStockThreshold,
    );

    final existing = await _alertaRepository.getOpenByInsumoAndType(
      insumo.id,
      AlertType.lowStock,
    );

    if (!shouldAlert) {
      if (existing != null) {
        await _alertaRepository.resolveAlert(existing.id);
      }
      return;
    }

    if (existing != null) {
      return;
    }

    final alerta = Alerta(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      insumoId: insumo.id,
      type: AlertType.lowStock,
      message: 'Stock bajo para ${insumo.name}.',
      createdAt: DateTime.now(),
      syncStatus: SyncStatus.pendingSync,
    );

    await _alertaRepository.upsertLocal(alerta, markPending: true);
  }
}
