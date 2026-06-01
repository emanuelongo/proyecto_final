import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../models/user_profile.dart';
import '../models/solicitud.dart';
import '../models/enums.dart'; // Aquí están tus enums como UserRole y SolicitudStatus
import '../services/auth_service.dart';
import '../services/user_profile_service.dart'; // Importación recuperada
import '../services/service_registry.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/loading_state.dart';
import '../widgets/status_chip.dart';
import '../widgets/sync_status_chip.dart';

class SolicitudesPage extends StatefulWidget {
  const SolicitudesPage({super.key});

  @override
  State<SolicitudesPage> createState() => _SolicitudesPageState();
}

class _CreateSolicitudPageState {} // Evita conflictos si existía una referencia fantasma

class _SolicitudesPageState extends State<SolicitudesPage> {
  final AuthService _authService = AuthService();
  final UserProfileService _profileService = UserProfileService(); // Restaurado de tu código base
  bool _syncing = false;
  String? _syncError;
  UserProfile? _profile;
  String? _userId;
  bool _loadingProfile = true;
  Map<String, String> _insumoNames = {};

  static const Color primaryPurple = Color(0xFF8F5DFA);

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _sync();
  }

  Future<void> _loadProfile() async {
    final user = _authService.currentUser;
    if (user == null) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        });
      }
      return;
    }

    final profile = await _profileService.fetchProfile(user.uid);
    await _loadInsumos();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _userId = user.uid;
      _loadingProfile = false;
    });
  }

  Future<void> _loadInsumos() async {
    final insumos = await ServiceRegistry.insumos.getAll();
    final names = <String, String>{};
    for (final insumo in insumos) {
      names[insumo.id] = insumo.name;
    }
    if (mounted) {
      setState(() {
        _insumoNames = names;
      });
    }
  }

  Future<void> _sync() async {
    setState(() {
      _syncing = true;
      _syncError = null;
    });
    try {
      await ServiceRegistry.syncService.syncAll();
    } catch (e) {
      _syncError = 'No se pudo sincronizar.';
    } finally {
      if (mounted) {
        setState(() {
          _syncing = false;
        });
      }
    }
  }

  Color _statusColor(SolicitudStatus status) {
    switch (status) {
      case SolicitudStatus.requested:
        return Colors.blueGrey;
      case SolicitudStatus.approved:
        return Colors.green;
      case SolicitudStatus.rejected:
        return Colors.red;
    }
  }

  String _statusLabel(SolicitudStatus status) {
    switch (status) {
      case SolicitudStatus.requested:
        return 'Solicitado';
      case SolicitudStatus.approved:
        return 'Aprobado';
      case SolicitudStatus.rejected:
        return 'Rechazado';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingProfile) {
      return const Scaffold(body: LoadingState());
    }

    final profile = _profile;
    final userId = _userId;
    if (profile == null || userId == null) {
      return const Scaffold(
        body: Center(child: Text('Sin perfil activo.')),
      );
    }

    final isDocente = profile.role == UserRole.docente;
    final isAuxiliar = profile.role == UserRole.auxiliar;
    final isAdmin = profile.role == UserRole.admin;
    final isDocenteOrAdmin = isDocente || isAdmin;

    final stream = isDocenteOrAdmin
        ? ServiceRegistry.solicitudes.watchLocal()
        : ServiceRegistry.solicitudes.watchByRequester(userId);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: const Text(
          'Solicitudes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _syncing ? null : _sync,
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar',
          ),
        ],
      ),
      floatingActionButton: isAuxiliar
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.createSolicitud),
              icon: const Icon(Icons.add),
              label: const Text('Nueva'),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // CONTENEDOR MORADO (Diseño de tu compañero con corrección de borderRadius)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryPurple,
                      Color(0xFF7B4FE0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20), // Corrección aplicada aquí adentro
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Solicitudes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isAuxiliar
                          ? 'Envía solicitudes desde aquí.'
                          : 'Revisa tus solicitudes registradas.',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<DateTime?>(
                      valueListenable: ServiceRegistry.syncState.lastSyncAt,
                      builder: (context, lastSyncAt, _) {
                        if (lastSyncAt == null) {
                          return const Text(
                            'Sin sincronización reciente',
                            style: TextStyle(color: Colors.white70),
                          );
                        }
                        final label = lastSyncAt.toLocal().toString().split('.').first;
                        return Text(
                          'Última sincronización: $label',
                          style: const TextStyle(color: Colors.white70),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (_syncError != null)
              MaterialBanner(
                content: Text(_syncError!),
                actions: [
                  TextButton(onPressed: _sync, child: const Text('Reintentar')),
                ],
              ),
            // LISTADO DE DATOS (Tu lógica de persistencia y backend conectada)
            Expanded(
              child: StreamBuilder<List<Solicitud>>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingState();
                  }
                  if (snapshot.hasError) {
                    return ErrorState(
                      message: 'Error al cargar solicitudes.',
                      onRetry: _sync,
                    );
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return const EmptyState(message: 'No hay solicitudes registradas.');
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final insumoName = _insumoNames[item.insumoId] ?? 'Insumo desconocido';
                      return Card(
                        child: ListTile(
                          title: Text(insumoName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cantidad: ${item.quantity}'),
                              Text('Solicitud: ${item.id}'),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              StatusChip(
                                label: _statusLabel(item.status),
                                color: _statusColor(item.status),
                              ),
                              const SizedBox(height: 6),
                              SyncStatusChip(status: item.syncStatus),
                            ],
                          ),
                          onTap: isDocente && item.status == SolicitudStatus.requested
                              ? () => _showReviewDialog(item, profile)
                              : null,
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: items.length,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReviewDialog(Solicitud solicitud, UserProfile profile) async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    _ReviewAction? selectedAction;
    final insumoName = _insumoNames[solicitud.insumoId] ?? 'Insumo desconocido';

    final result = await showDialog<_ReviewAction>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Revision de solicitud'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Insumo: $insumoName'),
                      const SizedBox(height: 8),
                      Text('Cantidad solicitada: ${solicitud.quantity}'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: reasonController,
                        decoration: const InputDecoration(
                          labelText: 'Motivo de rechazo',
                        ),
                        validator: (value) {
                          if (selectedAction == _ReviewAction.reject && (value == null || value.trim().isEmpty)) {
                            return 'El motivo de rechazo es obligatorio.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    selectedAction = _ReviewAction.reject;
                    if (formKey.currentState!.validate()) {
                      Navigator.of(context).pop(_ReviewAction.reject);
                    }
                  },
                  child: const Text('Rechazar'),
                ),
                FilledButton(
                  onPressed: () {
                    selectedAction = _ReviewAction.approve;
                    Navigator.of(context).pop(_ReviewAction.approve);
                  },
                  child: const Text('Aprobar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    try {
      if (result == _ReviewAction.approve) {
        final insumo = await ServiceRegistry.insumos.getById(solicitud.insumoId);
        if (insumo == null) {
          throw StateError('Insumo no encontrado.');
        }
        await ServiceRegistry.solicitudService.approveSolicitud(
          solicitud: solicitud,
          insumo: insumo,
          reviewerId: profile.uid,
        );
      } else {
        await ServiceRegistry.solicitudService.rejectSolicitud(
          solicitud: solicitud,
          reviewerId: profile.uid,
          reason: reasonController.text,
        );
      }
      await ServiceRegistry.syncService.syncAll();
    } catch (e) {
      if (mounted) {
        setState(() {
          _syncError = e is StateError ? e.message : 'No se pudo actualizar la solicitud.';
        });
      }
    }
  }
}

enum _ReviewAction { approve, reject }