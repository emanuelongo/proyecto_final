import 'repositories/insumo_repository.dart';
import 'repositories/lote_repository.dart';
import 'repositories/alerta_repository.dart';
import 'repositories/movimiento_repository.dart';
import 'repositories/solicitud_repository.dart';
import 'sync_state.dart';

class SyncService {
  SyncService({
    required InsumoRepository insumoRepository,
    required LoteRepository loteRepository,
    required SolicitudRepository solicitudRepository,
    required AlertaRepository alertaRepository,
    required MovimientoRepository movimientoRepository,
    required SyncState syncState,
  })  : _insumoRepository = insumoRepository,
        _loteRepository = loteRepository,
        _solicitudRepository = solicitudRepository,
        _alertaRepository = alertaRepository,
        _movimientoRepository = movimientoRepository,
        _syncState = syncState;

  final InsumoRepository _insumoRepository;
  final LoteRepository _loteRepository;
  final SolicitudRepository _solicitudRepository;
  final AlertaRepository _alertaRepository;
  final MovimientoRepository _movimientoRepository;
  final SyncState _syncState;

  Future<void> syncAll({int maxRetries = 3}) async {
    var attempt = 0;
    while (true) {
      try {
        await Future.wait([
          _insumoRepository.pushPending(),
          _loteRepository.pushPending(),
          _solicitudRepository.pushPending(),
          _alertaRepository.pushPending(),
          _movimientoRepository.pushPending(),
        ]);

        await Future.wait([
          _insumoRepository.pullRemote(),
          _loteRepository.pullRemote(),
          _solicitudRepository.pullRemote(),
          _alertaRepository.pullRemote(),
          _movimientoRepository.pullRemote(),
        ]);

        _syncState.markSuccess();
        return;
      } catch (e) {
        attempt += 1;
        _syncState.markError('Fallo de sincronizacion');
        if (attempt >= maxRetries) {
          rethrow;
        }
        final delayMs = 500 * (1 << (attempt - 1));
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
  }
}
