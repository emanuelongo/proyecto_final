import 'repositories/insumo_repository.dart';
import 'repositories/lote_repository.dart';
import 'repositories/alerta_repository.dart';
import 'repositories/movimiento_repository.dart';
import 'repositories/solicitud_repository.dart';

class SyncService {
  SyncService({
    required InsumoRepository insumoRepository,
    required LoteRepository loteRepository,
    required SolicitudRepository solicitudRepository,
    required AlertaRepository alertaRepository,
    required MovimientoRepository movimientoRepository,
  })  : _insumoRepository = insumoRepository,
        _loteRepository = loteRepository,
        _solicitudRepository = solicitudRepository,
        _alertaRepository = alertaRepository,
        _movimientoRepository = movimientoRepository;

  final InsumoRepository _insumoRepository;
  final LoteRepository _loteRepository;
  final SolicitudRepository _solicitudRepository;
  final AlertaRepository _alertaRepository;
  final MovimientoRepository _movimientoRepository;

  Future<void> syncAll() async {
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
  }
}
