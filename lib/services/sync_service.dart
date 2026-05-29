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
      final pullErrors = await _pullAll();
      final pushErrors = await _pushAll();
      final errors = [...pullErrors, ...pushErrors];

      if (errors.isEmpty) {
        _syncState.markSuccess();
        return;
      }

      attempt += 1;
      _syncState.markError('Fallo de sincronizacion');
      if (attempt >= maxRetries) {
        throw SyncException(errors);
      }
      final delayMs = 500 * (1 << (attempt - 1));
      await Future.delayed(Duration(milliseconds: delayMs));
    }
  }

  Future<List<String>> _pullAll() async {
    final errors = <String>[];
    final tasks = <(String, Future<void> Function())>[
      ('insumos', _insumoRepository.pullRemote),
      ('lotes', _loteRepository.pullRemote),
      ('solicitudes', _solicitudRepository.pullRemote),
      ('alertas', _alertaRepository.pullRemote),
      ('movimientos', _movimientoRepository.pullRemote),
    ];
    for (final task in tasks) {
      try {
        await task.$2();
      } catch (_) {
        errors.add(task.$1);
      }
    }
    return errors;
  }

  Future<List<String>> _pushAll() async {
    final errors = <String>[];
    final tasks = <(String, Future<void> Function())>[
      ('insumos', _insumoRepository.pushPending),
      ('lotes', _loteRepository.pushPending),
      ('solicitudes', _solicitudRepository.pushPending),
      ('alertas', _alertaRepository.pushPending),
      ('movimientos', _movimientoRepository.pushPending),
    ];
    for (final task in tasks) {
      try {
        await task.$2();
      } catch (_) {
        errors.add(task.$1);
      }
    }
    return errors;
  }
}

class SyncException implements Exception {
  SyncException(this.failedCollections);

  final List<String> failedCollections;

  @override
  String toString() => 'SyncException: ${failedCollections.join(', ')}';
}
