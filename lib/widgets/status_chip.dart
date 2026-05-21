import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.15),
      side: BorderSide(color: color),
      labelStyle: TextStyle(color: color),
    );
  }
}
