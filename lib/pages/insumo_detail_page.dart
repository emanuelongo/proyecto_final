import 'package:flutter/material.dart';

import '../models/insumo.dart';
import '../models/lote.dart';
import '../models/movimiento.dart';
import '../models/enums.dart';
import '../app_routes.dart';
import 'movement_page.dart';
import '../services/service_registry.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_state.dart';
import '../widgets/sync_status_chip.dart';

class InsumoDetailPage extends StatelessWidget {
  const InsumoDetailPage({super.key, required this.insumo});

  final Insumo insumo;

  @override
  Widget build(BuildContext context) {
    final lotesStream = ServiceRegistry.lotes.watchLocalByInsumo(insumo.id);
    final movimientosStream = ServiceRegistry.movimientos.watchLocalByInsumo(insumo.id);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(insumo.name),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.movement,
                  arguments: MovementArgs(insumo),
                );
              },
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Registrar movimiento',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Lotes'),
              Tab(text: 'Movimientos'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Unidad: ${insumo.unit}'),
              const SizedBox(height: 8),
              Text('Cantidad total: ${insumo.totalQuantity}'),
              const SizedBox(height: 8),
              SyncStatusChip(status: insumo.syncStatus),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: [
                    StreamBuilder<List<Lote>>(
                      stream: lotesStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const LoadingState();
                        }
                        final lotes = snapshot.data ?? [];
                        if (lotes.isEmpty) {
                          return const EmptyState(message: 'No hay lotes registrados.');
                        }
                        return ListView.separated(
                          itemCount: lotes.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final lote = lotes[index];
                            return _LoteCard(lote: lote);
                          },
                        );
                      },
                    ),
                    StreamBuilder<List<Movimiento>>(
                      stream: movimientosStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const LoadingState();
                        }
                        final movimientos = snapshot.data ?? [];
                        if (movimientos.isEmpty) {
                          return const EmptyState(message: 'No hay movimientos registrados.');
                        }
                        return ListView.separated(
                          itemCount: movimientos.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final movimiento = movimientos[index];
                            return _MovimientoCard(movimiento: movimiento);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoteCard extends StatelessWidget {
  const _LoteCard({required this.lote});

  final Lote lote;

  @override
  Widget build(BuildContext context) {
    final expiration = lote.expirationDate;
    final expirationLabel = expiration == null
        ? 'Sin vencimiento'
        : 'Vence: ${expiration.toLocal().toString().split(' ').first}';

    return Card(
      child: ListTile(
        title: Text('Lote ${lote.id}'),
        subtitle: Text('Cantidad: ${lote.quantity}\n$expirationLabel'),
        trailing: SyncStatusChip(status: lote.syncStatus),
      ),
    );
  }
}

class _MovimientoCard extends StatelessWidget {
  const _MovimientoCard({required this.movimiento});

  final Movimiento movimiento;

  String _labelFor(MovementType type) {
    switch (type) {
      case MovementType.inbound:
        return 'Entrada';
      case MovementType.outbound:
        return 'Salida';
      case MovementType.adjustment:
        return 'Ajuste';
    }
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = movimiento.createdAt;
    final createdLabel = createdAt == null
        ? 'Sin fecha'
        : createdAt.toLocal().toString().split(' ').first;

    return Card(
      child: ListTile(
        title: Text('${_labelFor(movimiento.type)} - ${movimiento.quantity}'),
        subtitle: Text('Fecha: $createdLabel'),
        trailing: SyncStatusChip(status: movimiento.syncStatus),
      ),
    );
  }
}
