import '../models/enums.dart';
import '../models/lote.dart';

class RulesService {
  const RulesService();

  bool isLoteExpired(Lote lote, {DateTime? at}) {
    final now = at ?? DateTime.now();
    final expirationDate = lote.expirationDate;
    if (expirationDate == null) {
      return false;
    }
    return expirationDate.isBefore(now) || expirationDate.isAtSameMomentAs(now);
  }

  bool canUseLote(Lote lote, {DateTime? at}) {
    return !isLoteExpired(lote, at: at);
  }

  bool validateStock(int available, int requested) {
    return requested > 0 && requested <= available;
  }

  bool shouldTriggerLowStock(int totalQty, {int threshold = 5}) {
    return totalQty > 0 && totalQty <= threshold;
  }

  InventoryStatus computeInventoryStatus({
    required int totalQty,
    required bool hasExpired,
    int lowStockThreshold = 5,
  }) {
    if (totalQty <= 0) {
      return InventoryStatus.outOfStock;
    }
    if (hasExpired) {
      return InventoryStatus.expired;
    }
    if (totalQty <= lowStockThreshold) {
      return InventoryStatus.lowStock;
    }
    return InventoryStatus.available;
  }

  bool canTransitionSolicitud(SolicitudStatus from, SolicitudStatus to) {
    const transitions = {
      SolicitudStatus.requested: [
        SolicitudStatus.approved,
        SolicitudStatus.rejected,
      ],
      SolicitudStatus.approved: [],
      SolicitudStatus.rejected: [],
    };

    final allowed = transitions[from] ?? const <SolicitudStatus>[];
    return allowed.contains(to);
  }

  int applyMovement({
    required int currentQty,
    required MovementType type,
    required int quantity,
  }) {
    switch (type) {
      case MovementType.inbound:
        return currentQty + quantity;
      case MovementType.outbound:
        return currentQty - quantity;
      case MovementType.adjustment:
        return quantity;
    }
  }
}
