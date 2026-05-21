import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/enums.dart';

class UserAdminService {
  UserAdminService({FirebaseFirestore? firestore})
      : _collection = (firestore ?? FirebaseFirestore.instance).collection('users');

  final CollectionReference<Map<String, dynamic>> _collection;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchUsers() {
    return _collection.snapshots();
  }

  Future<void> updateUser({
    required String uid,
    required UserRole role,
    required AccountStatus status,
  }) async {
    await _collection.doc(uid).update({
      'role': role.name,
      'status': status.name,
    });
  }
}
