import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/alerta.dart';
import '../models/insumo.dart';
import '../app_routes.dart';
import '../services/service_registry.dart';
import '../services/sync_service.dart';
import '../widgets/alert_list.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/loading_state.dart';
import '../widgets/status_chip.dart';
import '../widgets/sync_status_chip.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class InsumoDetailArgs {
  InsumoDetailArgs(this.insumo);

  final Insumo insumo;
}

class _InventoryPageState extends State<InventoryPage> {
  bool _syncing = false;
  String? _syncError;
  static const Color primaryPurple = Color(0xFF8F5DFA);
  static const Color accentGreen = Color(0xFFB0FA5D);

  @override
  void initState() {
    super.initState();
    _sync(silent: true);
  }

  Future<void> _sync({bool silent = false}) async {
    setState(() {
      _syncing = true;
      if (!silent) {
        _syncError = null;
      }
    });
    try {
      await ServiceRegistry.syncService.syncAll();
      if (mounted && !silent) {
        setState(() => _syncError = null);
      }
    } on FirebaseException catch (e) {
      if (!silent && mounted) {
        setState(() => _syncError = _messageForFirestoreError(e));
      }
    } on SyncException catch (e) {
      if (!silent && mounted) {
        setState(() => _syncError = _messageForSyncException(e));
      }
    } catch (_) {
      if (!silent && mounted) {
        setState(() => _syncError = 'No se pudo sincronizar la copia local.');
      }
    } finally {
      if (mounted) {
        setState(() => _syncing = false);
      }
    }
  }

  String _messageForFirestoreError(FirebaseException e) {
    if (e.code == 'permission-denied') {
      return 'Sin permiso en Firestore. Revisa las reglas publicadas.';
    }
    return 'Error de Firestore (${e.code}).';
  }

  String _messageForSyncException(SyncException e) {
    if (e.failedCollections.contains('insumos') || e.failedCollections.contains('lotes')) {
      return 'No se pudo actualizar inventario: ${e.failedCollections.join(', ')}.';
    }
    return 'Copia local parcial (${e.failedCollections.join(', ')}). El inventario en linea sigue disponible.';
  }

  Color _inventoryColor(InventoryStatus status) {
    switch (status) {
      case InventoryStatus.available:
        return Colors.green;
      case InventoryStatus.lowStock:
        return Colors.orange;
      case InventoryStatus.outOfStock:
        return Colors.red;
      case InventoryStatus.expired:
        return Colors.purple;
    }
  }

  String _inventoryLabel(InventoryStatus status) {
    switch (status) {
      case InventoryStatus.available:
        return 'Disponible';
      case InventoryStatus.lowStock:
        return 'Stock bajo';
      case InventoryStatus.outOfStock:
        return 'Agotado';
      case InventoryStatus.expired:
        return 'Vencido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = ServiceRegistry.insumos.watchRemote();
    final lastSyncNotifier = ServiceRegistry.syncState.lastSyncAt;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: const Text(
          'Inventario',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_syncing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              onPressed: () => _sync(),
              icon: const Icon(Icons.sync),
              tooltip: 'Sincronizar copia local',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Inventario',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<DateTime?>(
                      valueListenable: lastSyncNotifier,
                      builder: (context, lastSyncAt, _) {
                        if (lastSyncAt == null) {
                          return const Text(
                            'Sin copia local reciente',
                            style: TextStyle(color: Colors.white70),
                          );
                        }
                        final label = lastSyncAt.toLocal().toString().split('.').first;
                        return Text(
                          'Última copia local: $label',
                          style: const TextStyle(color: Colors.white70),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            if (_syncError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Material(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    title: Text(
                      _syncError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontSize: 13,
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: () => _sync(),
                      child: const Text('Reintentar'),
                    ),
                  ),
                ),
              ),

            Expanded(
              child: StreamBuilder<List<Insumo>>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingState();
                  }
                  if (snapshot.hasError) {
                    final error = snapshot.error;
                    final message = error is FirebaseException
                        ? _messageForFirestoreError(error)
                        : 'Error al cargar inventario.';
                    return ErrorState(
                      message: message,
                      onRetry: () => _sync(),
                    );
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return const EmptyState(message: 'No hay insumos registrados.');
                  }
                  return StreamBuilder<List<Alerta>>(
                    stream: ServiceRegistry.alertas.watchLocal(),
                    builder: (context, alertSnapshot) {
                      final alertas = alertSnapshot.data ?? [];
                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return AlertList(alertas: alertas);
                          }
                          final item = items[index - 1];
                          return _InsumoCard(
                            insumo: item,
                            statusLabel: _inventoryLabel(item.status),
                            statusColor: _inventoryColor(item.status),
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.insumoDetail,
                                arguments: InsumoDetailArgs(item),
                              );
                            },
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemCount: items.length + 1,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsumoCard extends StatelessWidget {
  const _InsumoCard({
    required this.insumo,
    required this.statusLabel,
    required this.statusColor,
    required this.onTap,
  });

  final Insumo insumo;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                insumo.name.trim(),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                '${insumo.totalQuantity} ${insumo.unit}',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  StatusChip(label: statusLabel, color: statusColor),
                  if (insumo.syncStatus != SyncStatus.synced)
                    SyncStatusChip(status: insumo.syncStatus),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
