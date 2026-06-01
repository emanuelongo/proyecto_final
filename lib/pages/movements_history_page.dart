import 'package:flutter/material.dart';

import '../models/movimiento.dart';
import '../models/enums.dart';
import '../services/service_registry.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_state.dart';
import '../widgets/sync_status_chip.dart';

class MovementsHistoryPage extends StatelessWidget {
  const MovementsHistoryPage({super.key});

  static const Color primaryPurple = Color(0xFF8F5DFA);

  @override
  Widget build(BuildContext context) {
    final stream = ServiceRegistry.movimientos.watchLocal();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: const Text(
          'Historial de movimientos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<Movimiento>>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingState();
            }
            final movimientos = snapshot.data ?? [];
            if (movimientos.isEmpty) {
              return const EmptyState(message: 'No hay movimientos registrados.');
            }
            return Column(
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
                          'Movimientos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Registrados: ${movimientos.length}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: movimientos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final movimiento = movimientos[index];
                      return _MovimientoCard(movimiento: movimiento);
                    },
                  ),
                ),
              ],
            );
          },
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
        : createdAt.toLocal().toString().split('.').first;

    return Card(
      child: ListTile(
        title: Text('${_labelFor(movimiento.type)} - ${movimiento.quantity}'),
        subtitle: Text('Fecha: $createdLabel'),
        trailing: SyncStatusChip(status: movimiento.syncStatus),
      ),
    );
  }
}
