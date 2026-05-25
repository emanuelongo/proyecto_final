import '../data/app_database.dart';
import 'inventory_service.dart';
import 'repositories/alerta_repository.dart';
import 'repositories/insumo_repository.dart';
import 'repositories/lote_repository.dart';
import 'repositories/movimiento_repository.dart';
import 'repositories/solicitud_repository.dart';
import 'sync_service.dart';
import 'movement_service.dart';
import 'solicitud_service.dart';
import 'sync_state.dart';

class ServiceRegistry {
  static final AppDatabase db = AppDatabase();
  static final AlertaRepository alertas = AlertaRepository(db);
  static final InventoryService inventoryService = InventoryService(
    alertaRepository: alertas,
  );
  static final InsumoRepository insumos = InsumoRepository(
    db,
    inventoryService: inventoryService,
  );
  static final LoteRepository lotes = LoteRepository(db);
  static final MovimientoRepository movimientos = MovimientoRepository(db);
  static final SolicitudRepository solicitudes = SolicitudRepository(db);
  static final MovementService movementService = MovementService(
    insumoRepository: insumos,
    loteRepository: lotes,
    movimientoRepository: movimientos,
  );
  static final SolicitudService solicitudService = SolicitudService(
    solicitudRepository: solicitudes,
    movementService: movementService,
  );
  static final SyncState syncState = SyncState();
  static final SyncService syncService = SyncService(
    insumoRepository: insumos,
    loteRepository: lotes,
    solicitudRepository: solicitudes,
    alertaRepository: alertas,
    movimientoRepository: movimientos,
    syncState: syncState,
  );
}
