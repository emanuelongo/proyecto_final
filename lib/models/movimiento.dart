import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';
import 'model_utils.dart';

class Movimiento {
  const Movimiento({
    required this.id,
    required this.insumoId,
    this.loteId,
    required this.type,
    required this.quantity,
    required this.createdBy,
    this.createdAt,
    this.syncStatus = SyncStatus.synced,
  });

  final String id;
  final String insumoId;
  final String? loteId;
  final MovementType type;
  final int quantity;
  final String createdBy;
  final DateTime? createdAt;
  final SyncStatus syncStatus;

  Movimiento copyWith({
    String? id,
    String? insumoId,
    String? loteId,
    MovementType? type,
    int? quantity,
    String? createdBy,
    DateTime? createdAt,
    SyncStatus? syncStatus,
  }) {
    return Movimiento(
      id: id ?? this.id,
      insumoId: insumoId ?? this.insumoId,
      loteId: loteId ?? this.loteId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  factory Movimiento.fromMap(Map<String, dynamic> map) {
    final type = enumFromString(MovementType.values, map['type']) ?? MovementType.adjustment;
    final syncStatus = enumFromString(SyncStatus.values, map['syncStatus']) ?? SyncStatus.synced;

    return Movimiento(
      id: (map['id'] ?? '').toString(),
      insumoId: (map['insumoId'] ?? '').toString(),
      loteId: map['loteId']?.toString(),
      type: type,
      quantity: intFromValue(map['quantity']),
      createdBy: (map['createdBy'] ?? '').toString(),
      createdAt: dateFromValue(map['createdAt']),
      syncStatus: syncStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'insumoId': insumoId,
      'loteId': loteId,
      'type': type.name,
      'quantity': quantity,
      'createdBy': createdBy,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      'syncStatus': syncStatus.name,
    };
  }
}
