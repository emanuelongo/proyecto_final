import 'package:connectivity_plus/connectivity_plus.dart';

import 'sync_service.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();

  factory ConnectivityService() {
    return _instance;
  }

  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  SyncService? _syncService;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  void initialize(SyncService syncService) {
    _syncService = syncService;
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final hasConnection =
          !results.contains(ConnectivityResult.none);

      if (hasConnection && !_isOnline) {
        // Reconexión detectada
        _isOnline = true;
        _attemptSync();
      } else if (!hasConnection && _isOnline) {
        // Pérdida de conexión
        _isOnline = false;
      }
    });
  }

  Future<void> _attemptSync() async {
    if (_syncService == null) return;
    try {
      await _syncService!.syncAll();
    } catch (_) {
      // Error en sync, se reintentará en el próximo cambio
    }
  }

  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = !result.contains(ConnectivityResult.none);
    return _isOnline;
  }
}
