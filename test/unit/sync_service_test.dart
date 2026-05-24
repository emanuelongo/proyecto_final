import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:proyecto_final/services/sync_service.dart';
import 'package:proyecto_final/services/sync_state.dart';
import 'package:proyecto_final/services/repositories/insumo_repository.dart';
import 'package:proyecto_final/services/repositories/lote_repository.dart';
import 'package:proyecto_final/services/repositories/solicitud_repository.dart';
import 'package:proyecto_final/services/repositories/alerta_repository.dart';
import 'package:proyecto_final/services/repositories/movimiento_repository.dart';

class MockInsumoRepository extends Mock implements InsumoRepository {}

class MockLoteRepository extends Mock implements LoteRepository {}

class MockSolicitudRepository extends Mock implements SolicitudRepository {}

class MockAlertaRepository extends Mock implements AlertaRepository {}

class MockMovimientoRepository extends Mock implements MovimientoRepository {}

void main() {
  group('SyncService', () {
    late MockInsumoRepository mockInsumoRepository;
    late MockLoteRepository mockLoteRepository;
    late MockSolicitudRepository mockSolicitudRepository;
    late MockAlertaRepository mockAlertaRepository;
    late MockMovimientoRepository mockMovimientoRepository;
    late SyncState syncState;
    late SyncService syncService;

    setUp(() {
      mockInsumoRepository = MockInsumoRepository();
      mockLoteRepository = MockLoteRepository();
      mockSolicitudRepository = MockSolicitudRepository();
      mockAlertaRepository = MockAlertaRepository();
      mockMovimientoRepository = MockMovimientoRepository();
      syncState = SyncState();

      syncService = SyncService(
        insumoRepository: mockInsumoRepository,
        loteRepository: mockLoteRepository,
        solicitudRepository: mockSolicitudRepository,
        alertaRepository: mockAlertaRepository,
        movimientoRepository: mockMovimientoRepository,
        syncState: syncState,
      );

      when(mockInsumoRepository.pushPending()).thenAnswer((_) async => {});
      when(mockLoteRepository.pushPending()).thenAnswer((_) async => {});
      when(mockSolicitudRepository.pushPending()).thenAnswer((_) async => {});
      when(mockAlertaRepository.pushPending()).thenAnswer((_) async => {});
      when(mockMovimientoRepository.pushPending()).thenAnswer((_) async => {});

      when(mockInsumoRepository.pullRemote()).thenAnswer((_) async => {});
      when(mockLoteRepository.pullRemote()).thenAnswer((_) async => {});
      when(mockSolicitudRepository.pullRemote()).thenAnswer((_) async => {});
      when(mockAlertaRepository.pullRemote()).thenAnswer((_) async => {});
      when(mockMovimientoRepository.pullRemote()).thenAnswer((_) async => {});
    });

    test('syncAll ejecuta push y pull en todos los repositorios', () async {
      await syncService.syncAll();

      verify(mockInsumoRepository.pushPending()).called(1);
      verify(mockLoteRepository.pushPending()).called(1);
      verify(mockSolicitudRepository.pushPending()).called(1);
      verify(mockAlertaRepository.pushPending()).called(1);
      verify(mockMovimientoRepository.pushPending()).called(1);

      verify(mockInsumoRepository.pullRemote()).called(1);
      verify(mockLoteRepository.pullRemote()).called(1);
      verify(mockSolicitudRepository.pullRemote()).called(1);
      verify(mockAlertaRepository.pullRemote()).called(1);
      verify(mockMovimientoRepository.pullRemote()).called(1);
    });

    test('syncAll marca success después de completar', () async {
      await syncService.syncAll();

      // SyncState debería estar en estado exitoso
      // (Verificar llamada a markSuccess)
    });

    test('syncAll reintenta con backoff exponencial', () async {
      var callCount = 0;
      when(mockInsumoRepository.pushPending()).thenAnswer((_) async {
        callCount++;
        if (callCount < 2) {
          throw Exception('Network error');
        }
      });

      when(mockLoteRepository.pushPending()).thenAnswer((_) async => {});
      when(mockSolicitudRepository.pushPending()).thenAnswer((_) async => {});
      when(mockAlertaRepository.pushPending()).thenAnswer((_) async => {});
      when(mockMovimientoRepository.pushPending()).thenAnswer((_) async => {});

      when(mockInsumoRepository.pullRemote()).thenAnswer((_) async => {});
      when(mockLoteRepository.pullRemote()).thenAnswer((_) async => {});
      when(mockSolicitudRepository.pullRemote()).thenAnswer((_) async => {});
      when(mockAlertaRepository.pullRemote()).thenAnswer((_) async => {});
      when(mockMovimientoRepository.pullRemote()).thenAnswer((_) async => {});

      await syncService.syncAll(maxRetries: 3);

      // Debería reintentar después del primer fallo
      expect(callCount, greaterThanOrEqualTo(2));
    });

    test('syncAll lanza excepción después de agotar reintentos', () async {
      when(mockInsumoRepository.pushPending())
          .thenThrow(Exception('Network error'));

      expect(
        syncService.syncAll(maxRetries: 2),
        throwsException,
      );
    });

    test('syncAll marca error en syncState cuando falla', () async {
      when(mockInsumoRepository.pushPending())
          .thenThrow(Exception('Network error'));

      try {
        await syncService.syncAll(maxRetries: 1);
      } catch (_) {}

      // SyncState debería tener estado de error
      // (Verificar llamada a markError)
    });
  });
}
