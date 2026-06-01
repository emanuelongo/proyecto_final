import '../models/enums.dart';
import '../models/insumo.dart';
import '../models/solicitud.dart';
import '../services/rules_service.dart';
import 'movement_service.dart';
import 'repositories/solicitud_repository.dart';

class SolicitudService {
  SolicitudService({
    required SolicitudRepository solicitudRepository,
    required MovementService movementService,
    RulesService? rulesService,
  })  : _solicitudRepository = solicitudRepository,
        _movementService = movementService,
        _rulesService = rulesService ?? const RulesService();

  final SolicitudRepository _solicitudRepository;
  final MovementService _movementService;
  final RulesService _rulesService;

  Future<void> approveSolicitud({
    required Solicitud solicitud,
    required Insumo insumo,
    required String reviewerId,
  }) async {
    print('=== SolicitudService.approveSolicitud ===');
    print('Aprobando solicitud ${solicitud.id} para insumo ${insumo.id}');

    if (!_rulesService.canTransitionSolicitud(solicitud.status, SolicitudStatus.approved)) {
      throw StateError('Transicion no permitida.');
    }

    await _movementService.registerOutbound(
      insumo: insumo,
      quantity: solicitud.quantity,
      userId: reviewerId,
    );
    print('registerOutbound completado');

    final updated = solicitud.copyWith(
      status: SolicitudStatus.approved,
      reviewerId: reviewerId,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingSync,
    );

    await _solicitudRepository.upsertLocal(updated, markPending: true);
    print('Solicitud actualizada en local');
  }

  Future<void> rejectSolicitud({
    required Solicitud solicitud,
    required String reviewerId,
    required String reason,
  }) async {
    if (reason.trim().isEmpty) {
      throw StateError('Motivo obligatorio.');
    }
    if (!_rulesService.canTransitionSolicitud(solicitud.status, SolicitudStatus.rejected)) {
      throw StateError('Transicion no permitida.');
    }

    final updated = solicitud.copyWith(
      status: SolicitudStatus.rejected,
      reviewerId: reviewerId,
      rejectionReason: reason.trim(),
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingSync,
    );

    await _solicitudRepository.upsertLocal(updated, markPending: true);
  }
}
