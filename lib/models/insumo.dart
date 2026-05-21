import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';
import 'model_utils.dart';

class Insumo {
  const Insumo({
    required this.id,
    required this.name,
    required this.unit,
    required this.totalQuantity,
    required this.status,
    required this.lowStockThreshold,
    this.createdAt,
    this.updatedAt,
    this.syncStatus = SyncStatus.synced,
  });

  final String id;
  final String name;
  final String unit;
  final int totalQuantity;
  final InventoryStatus status;
  final int lowStockThreshold;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SyncStatus syncStatus;

  Insumo copyWith({
    String? id,
    String? name,
    String? unit,
    int? totalQuantity,
    InventoryStatus? status,
    int? lowStockThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return Insumo(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      status: status ?? this.status,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  factory Insumo.fromMap(Map<String, dynamic> map) {
    final status = enumFromString(InventoryStatus.values, map['status']) ?? InventoryStatus.available;
    final syncStatus = enumFromString(SyncStatus.values, map['syncStatus']) ?? SyncStatus.synced;

    return Insumo(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      unit: (map['unit'] ?? '').toString(),
      totalQuantity: intFromValue(map['totalQuantity']),
      status: status,
      lowStockThreshold: intFromValue(map['lowStockThreshold']),
      createdAt: dateFromValue(map['createdAt']),
      updatedAt: dateFromValue(map['updatedAt']),
      syncStatus: syncStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'totalQuantity': totalQuantity,
      'status': status.name,
      'lowStockThreshold': lowStockThreshold,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
      'syncStatus': syncStatus.name,
    };
  }
}
