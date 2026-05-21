import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/alerta.dart';
import '../models/insumo.dart';
import '../app_routes.dart';
import '../services/service_registry.dart';
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

  @override
  void initState() {
    super.initState();
    _sync();
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
    final stream = ServiceRegistry.insumos.watchLocal();
    final lastSyncNotifier = ServiceRegistry.syncState.lastSyncAt;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          IconButton(
            onPressed: _syncing ? null : _sync,
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar',
          ),
        ],
      ),
      body: Column(
        children: [
          ValueListenableBuilder<DateTime?>(
            valueListenable: lastSyncNotifier,
            builder: (context, lastSyncAt, _) {
              if (lastSyncAt == null) {
                return const SizedBox.shrink();
              }
              final label = lastSyncAt.toLocal().toString().split('.').first;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Ultima sincronizacion: $label'),
              );
            },
          ),
          if (_syncError != null)
            MaterialBanner(
              content: Text(_syncError!),
              actions: [
                TextButton(onPressed: _sync, child: const Text('Reintentar')),
              ],
            ),
          Expanded(
            child: StreamBuilder<List<Insumo>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState();
                }
                if (snapshot.hasError) {
                  return ErrorState(
                    message: 'Error al cargar inventario.',
                    onRetry: _sync,
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
                        return Card(
                          child: ListTile(
                            title: Text(item.name),
                            subtitle: Text('Cantidad: ${item.totalQuantity} ${item.unit}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                StatusChip(
                                  label: _inventoryLabel(item.status),
                                  color: _inventoryColor(item.status),
                                ),
                                const SizedBox(height: 6),
                                SyncStatusChip(status: item.syncStatus),
                              ],
                            ),
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.insumoDetail,
                                arguments: InsumoDetailArgs(item),
                              );
                            },
                          ),
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
    );
  }
}
