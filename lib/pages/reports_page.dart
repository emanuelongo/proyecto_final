import 'package:flutter/material.dart';

import '../models/alerta.dart';
import '../models/enums.dart';
import '../models/insumo.dart';
import '../services/service_registry.dart';
import '../widgets/loading_state.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final insumosStream = ServiceRegistry.insumos.watchLocal();
    final alertasStream = ServiceRegistry.alertas.watchLocal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de inventario'),
      ),
      body: StreamBuilder<List<Insumo>>(
        stream: insumosStream,
        builder: (context, insumoSnapshot) {
          if (insumoSnapshot.connectionState == ConnectionState.waiting) {
            return const LoadingState();
          }
          final insumos = insumoSnapshot.data ?? [];

          return StreamBuilder<List<Alerta>>(
            stream: alertasStream,
            builder: (context, alertSnapshot) {
              if (alertSnapshot.connectionState == ConnectionState.waiting) {
                return const LoadingState();
              }
              final alertas = alertSnapshot.data ?? [];

              final total = insumos.length;
              final available = insumos.where((i) => i.status == InventoryStatus.available).length;
              final lowStock = insumos.where((i) => i.status == InventoryStatus.lowStock).length;
              final outOfStock = insumos.where((i) => i.status == InventoryStatus.outOfStock).length;
              final expired = insumos.where((i) => i.status == InventoryStatus.expired).length;

              final lowStockAlerts =
                  alertas.where((a) => a.type == AlertType.lowStock && !a.resolved).length;
              final expiredAlerts =
                  alertas.where((a) => a.type == AlertType.expired && !a.resolved).length;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _StatCard(label: 'Total insumos', value: total.toString()),
                  const SizedBox(height: 8),
                  _StatCard(label: 'Disponibles', value: available.toString()),
                  const SizedBox(height: 8),
                  _StatCard(label: 'Stock bajo', value: lowStock.toString()),
                  const SizedBox(height: 8),
                  _StatCard(label: 'Agotados', value: outOfStock.toString()),
                  const SizedBox(height: 8),
                  _StatCard(label: 'Vencidos', value: expired.toString()),
                  const SizedBox(height: 16),
                  Text('Alertas activas', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _StatCard(label: 'Stock bajo', value: lowStockAlerts.toString()),
                  const SizedBox(height: 8),
                  _StatCard(label: 'Vencidas', value: expiredAlerts.toString()),
                  const SizedBox(height: 16),
                  Text('Distribucion por estado', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _BarRow(label: 'Disponible', value: available, total: total, color: Colors.green),
                  _BarRow(label: 'Stock bajo', value: lowStock, total: total, color: Colors.orange),
                  _BarRow(label: 'Agotado', value: outOfStock, total: total, color: Colors.red),
                  _BarRow(label: 'Vencido', value: expired, total: total, color: Colors.purple),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(value, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  final String label;
  final int value;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : value / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label)),
          Expanded(
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 32, child: Text(value.toString())),
        ],
      ),
    );
  }
}
