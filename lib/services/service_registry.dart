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
import 'connectivity_service.dart';

class ServiceRegistry {
  static final ServiceRegistry _instance = ServiceRegistry._internal();
  static late AppDatabase _db;
  static late AlertaRepository _alertas;
  static late InventoryService _inventoryService;
  static late InsumoRepository _insumos;
  static late LoteRepository _lotes;
  static late MovimientoRepository _movimientos;
  static late SolicitudRepository _solicitudes;
  static late MovementService _movementService;
  static late SolicitudService _solicitudService;
  static late SyncState _syncState;
  static late SyncService _syncService;
  static late ConnectivityService _connectivityService;

  factory ServiceRegistry() {
    return _instance;
  }

  ServiceRegistry._internal();

  static ServiceRegistry get instance => _instance;

  static void initialize() {
    _db = AppDatabase();
    _alertas = AlertaRepository(_db);
    _inventoryService = InventoryService(
      alertaRepository: _alertas,
    );
    _insumos = InsumoRepository(
      _db,
      inventoryService: _inventoryService,
    );
    _lotes = LoteRepository(_db);
    _movimientos = MovimientoRepository(_db);
    _solicitudes = SolicitudRepository(_db);
    _movementService = MovementService(
      insumoRepository: _insumos,
      loteRepository: _lotes,
      movimientoRepository: _movimientos,
    );
    _solicitudService = SolicitudService(
      solicitudRepository: _solicitudes,
      movementService: _movementService,
    );
    _syncState = SyncState();
    _syncService = SyncService(
      insumoRepository: _insumos,
      loteRepository: _lotes,
      solicitudRepository: _solicitudes,
      alertaRepository: _alertas,
      movimientoRepository: _movimientos,
      syncState: _syncState,
    );
    _connectivityService = ConnectivityService();
    _connectivityService.initialize(_syncService);
  }

  // Getters estáticos para compatibilidad
  static AppDatabase get db => _db;
  static AlertaRepository get alertas => _alertas;
  static InventoryService get inventoryService => _inventoryService;
  static InsumoRepository get insumos => _insumos;
  static LoteRepository get lotes => _lotes;
  static MovimientoRepository get movimientos => _movimientos;
  static SolicitudRepository get solicitudes => _solicitudes;
  static MovementService get movementService => _movementService;
  static SolicitudService get solicitudService => _solicitudService;
  static SyncState get syncState => _syncState;
  static SyncService get syncService => _syncService;
  static ConnectivityService get connectivityService => _connectivityService;
}
