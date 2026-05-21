import 'enums.dart';
import 'model_utils.dart';

class Solicitud {
  const Solicitud({
    required this.id,
    required this.insumoId,
    required this.requestedBy,
    required this.quantity,
    required this.status,
    this.reviewerId,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
    this.syncStatus = SyncStatus.synced,
  });

  final String id;
  final String insumoId;
  final String requestedBy;
  final int quantity;
  final SolicitudStatus status;
  final String? reviewerId;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SyncStatus syncStatus;

  Solicitud copyWith({
    String? id,
    String? insumoId,
    String? requestedBy,
    int? quantity,
    SolicitudStatus? status,
    String? reviewerId,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return Solicitud(
      id: id ?? this.id,
      insumoId: insumoId ?? this.insumoId,
      requestedBy: requestedBy ?? this.requestedBy,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      reviewerId: reviewerId ?? this.reviewerId,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  factory Solicitud.fromMap(Map<String, dynamic> map) {
    final status =
        enumFromString(SolicitudStatus.values, map['status']) ?? SolicitudStatus.requested;
    final syncStatus = enumFromString(SyncStatus.values, map['syncStatus']) ?? SyncStatus.synced;

    return Solicitud(
      id: (map['id'] ?? '').toString(),
      insumoId: (map['insumoId'] ?? '').toString(),
      requestedBy: (map['requestedBy'] ?? '').toString(),
      quantity: (map['quantity'] ?? 0) as int,
      status: status,
      reviewerId: map['reviewerId']?.toString(),
      rejectionReason: map['rejectionReason']?.toString(),
      createdAt: dateFromValue(map['createdAt']),
      updatedAt: dateFromValue(map['updatedAt']),
      syncStatus: syncStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'insumoId': insumoId,
      'requestedBy': requestedBy,
      'quantity': quantity,
      'status': status.name,
      'reviewerId': reviewerId,
      'rejectionReason': rejectionReason,
      'createdAt': dateToString(createdAt),
      'updatedAt': dateToString(updatedAt),
      'syncStatus': syncStatus.name,
    };
  }
}
