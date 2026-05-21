import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';
import 'model_utils.dart';

class Alerta {
  const Alerta({
    required this.id,
    required this.insumoId,
    required this.type,
    required this.message,
    this.createdAt,
    this.resolved = false,
    this.syncStatus = SyncStatus.synced,
  });

  final String id;
  final String insumoId;
  final AlertType type;
  final String message;
  final DateTime? createdAt;
  final bool resolved;
  final SyncStatus syncStatus;

  Alerta copyWith({
    String? id,
    String? insumoId,
    AlertType? type,
    String? message,
    DateTime? createdAt,
    bool? resolved,
    SyncStatus? syncStatus,
  }) {
    return Alerta(
      id: id ?? this.id,
      insumoId: insumoId ?? this.insumoId,
      type: type ?? this.type,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      resolved: resolved ?? this.resolved,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  factory Alerta.fromMap(Map<String, dynamic> map) {
    final type = enumFromString(AlertType.values, map['type']) ?? AlertType.lowStock;
    final syncStatus = enumFromString(SyncStatus.values, map['syncStatus']) ?? SyncStatus.synced;

    return Alerta(
      id: (map['id'] ?? '').toString(),
      insumoId: (map['insumoId'] ?? '').toString(),
      type: type,
      message: (map['message'] ?? '').toString(),
      createdAt: dateFromValue(map['createdAt']),
      resolved: (map['resolved'] ?? false) as bool,
      syncStatus: syncStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'insumoId': insumoId,
      'type': type.name,
      'message': message,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      'resolved': resolved,
      'syncStatus': syncStatus.name,
    };
  }
}
