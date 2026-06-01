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

  static const Color primaryPurple = Color(0xFF8F5DFA);
  static const Color accentGreen = Color(0xFFB0FA5D);

  @override
  Widget build(BuildContext context) {
    final lotesStream = ServiceRegistry.lotes.watchRemoteByInsumo(insumo.id);
    final movimientosStream = ServiceRegistry.movimientos.watchLocalByInsumo(insumo.id);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          title: Text(
            insumo.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
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
                      Text(
                        insumo.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Unidad: ${insumo.unit} · Cantidad: ${insumo.totalQuantity}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      SyncStatusChip(status: insumo.syncStatus),
                    ],
                  ),
                ),

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
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final lote = lotes[index];
                              return _LoteCard(lote: lote, unit: insumo.unit);
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
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
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
      ),
    );
  }
}

String _loteDisplayCode(String id) {
  final normalized = id.trim();
  final match = RegExp(r'^lote[_-]?(.*)$', caseSensitive: false).firstMatch(normalized);
  if (match != null) {
    final code = match.group(1)?.trim();
    if (code != null && code.isNotEmpty) {
      return code;
    }
  }
  return normalized;
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year;
  return '$day/$month/$year';
}

class _LoteCard extends StatelessWidget {
  const _LoteCard({required this.lote, required this.unit});

  final Lote lote;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final code = _loteDisplayCode(lote.id);
    final expiration = lote.expirationDate?.toLocal();
    final now = DateTime.now();
    final isExpired = expiration != null && expiration.isBefore(now);
    final expiresSoon = expiration != null &&
        !isExpired &&
        expiration.isBefore(now.add(const Duration(days: 30)));

    Color? expirationColor;
    String expirationLabel;
    IconData expirationIcon;

    if (expiration == null) {
      expirationColor = theme.colorScheme.outline;
      expirationLabel = 'Sin fecha de vencimiento';
      expirationIcon = Icons.event_busy_outlined;
    } else if (isExpired) {
      expirationColor = theme.colorScheme.error;
      expirationLabel = 'Vencido el ${_formatDate(expiration)}';
      expirationIcon = Icons.warning_amber_rounded;
    } else if (expiresSoon) {
      expirationColor = Colors.orange;
      expirationLabel = 'Vence el ${_formatDate(expiration)}';
      expirationIcon = Icons.schedule;
    } else {
      expirationColor = theme.colorScheme.primary;
      expirationLabel = 'Vence el ${_formatDate(expiration)}';
      expirationIcon = Icons.event_outlined;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                code.length > 3 ? code.substring(0, 3) : code,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${lote.quantity} $unit',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(expirationIcon, size: 16, color: expirationColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          expirationLabel,
                          style: theme.textTheme.bodySmall?.copyWith(color: expirationColor),
                        ),
                      ),
                    ],
                  ),
                  if (lote.syncStatus != SyncStatus.synced) ...[
                    const SizedBox(height: 8),
                    SyncStatusChip(status: lote.syncStatus),
                  ],
                ],
              ),
            ),
          ],
        ),
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
