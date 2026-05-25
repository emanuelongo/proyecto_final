import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/enums.dart';

class UserAdminService {
  // 1. Constructor privado interno para evitar instancias externas directas
  UserAdminService._internal({FirebaseFirestore? firestore})
      : _collection = (firestore ?? FirebaseFirestore.instance).collection('users');

  // 2. La única instancia real que existirá en la memoria de la app
  static final UserAdminService _instance = UserAdminService._internal();

  // 3. Constructor factory: intercepta cualquier llamada a "UserAdminService()"
  // y en lugar de crear un objeto nuevo, devuelve siempre la misma _instance
  factory UserAdminService() => _instance;

  final CollectionReference<Map<String, dynamic>> _collection;

  // Al ser un Singleton, este Stream no se reiniciará al redibujar pantallas hijas
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