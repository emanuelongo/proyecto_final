import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';
import 'model_utils.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.createdAt,
    this.lastLoginAt,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final AccountStatus status;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    UserRole? role,
    AccountStatus? status,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final role = enumFromString(UserRole.values, map['role']) ?? UserRole.auxiliar;
    final status =
        enumFromString(AccountStatus.values, map['status']) ?? AccountStatus.pendingApproval;

    return UserProfile(
      uid: (map['uid'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      role: role,
      status: status,
      createdAt: dateFromValue(map['createdAt']),
      lastLoginAt: dateFromValue(map['lastLoginAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.name,
      'status': status.name,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      'lastLoginAt': lastLoginAt == null ? null : Timestamp.fromDate(lastLoginAt!),
    };
  }
}
