import 'package:flutter/material.dart';

import '../models/alerta.dart';
import '../models/enums.dart';
import 'status_chip.dart';

class AlertList extends StatelessWidget {
  const AlertList({super.key, required this.alertas});

  final List<Alerta> alertas;

  Color _colorFor(AlertType type) {
    switch (type) {
      case AlertType.lowStock:
        return Colors.orange;
      case AlertType.expired:
        return Colors.red;
    }
  }

  String _labelFor(AlertType type) {
    switch (type) {
      case AlertType.lowStock:
        return 'Stock bajo';
      case AlertType.expired:
        return 'Vencido';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (alertas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alertas',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...alertas.map(
          (alerta) => Card(
            child: ListTile(
              title: Text(alerta.message),
              subtitle: Text(alerta.insumoId),
              trailing: StatusChip(
                label: _labelFor(alerta.type),
                color: _colorFor(alerta.type),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
