import 'enums.dart';
import 'model_utils.dart';

class Lote {
  const Lote({
    required this.id,
    required this.insumoId,
    required this.quantity,
    this.expirationDate,
    this.createdAt,
    this.updatedAt,
    this.syncStatus = SyncStatus.synced,
  });

  final String id;
  final String insumoId;
  final int quantity;
  final DateTime? expirationDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SyncStatus syncStatus;

  Lote copyWith({
    String? id,
    String? insumoId,
    int? quantity,
    DateTime? expirationDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return Lote(
      id: id ?? this.id,
      insumoId: insumoId ?? this.insumoId,
      quantity: quantity ?? this.quantity,
      expirationDate: expirationDate ?? this.expirationDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  factory Lote.fromMap(Map<String, dynamic> map) {
    final syncStatus = enumFromString(SyncStatus.values, map['syncStatus']) ?? SyncStatus.synced;

    return Lote(
      id: (map['id'] ?? '').toString(),
      insumoId: (map['insumoId'] ?? '').toString(),
      quantity: (map['quantity'] ?? 0) as int,
      expirationDate: dateFromValue(map['expirationDate']),
      createdAt: dateFromValue(map['createdAt']),
      updatedAt: dateFromValue(map['updatedAt']),
      syncStatus: syncStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'insumoId': insumoId,
      'quantity': quantity,
      'expirationDate': dateToString(expirationDate),
      'createdAt': dateToString(createdAt),
      'updatedAt': dateToString(updatedAt),
      'syncStatus': syncStatus.name,
    };
  }
}
