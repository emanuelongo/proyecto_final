import 'package:flutter_test/flutter_test.dart';

import 'package:proyecto_final/models/enums.dart';
import 'package:proyecto_final/models/user_profile.dart';
import 'package:proyecto_final/services/permission_service.dart';

void main() {
  group('PermissionService', () {
    final service = PermissionService();

    UserProfile user({required UserRole role, required AccountStatus status}) {
      return UserProfile(
        uid: 'u1',
        name: 'Test',
        email: 'test@example.com',
        role: role,
        status: status,
      );
    }

    test('active auxiliar can create solicitud', () {
      final profile = user(role: UserRole.auxiliar, status: AccountStatus.active);
      expect(service.canCreateSolicitud(profile), isTrue);
    });

    test('pendingApproval cannot create solicitud', () {
      final profile = user(role: UserRole.auxiliar, status: AccountStatus.pendingApproval);
      expect(service.canCreateSolicitud(profile), isFalse);
    });

    test('blocked cannot access module', () {
      final profile = user(role: UserRole.auxiliar, status: AccountStatus.blocked);
      expect(service.canAccessModule(profile), isFalse);
    });

    test('docente can approve solicitud', () {
      final profile = user(role: UserRole.docente, status: AccountStatus.active);
      expect(service.canApproveSolicitud(profile), isTrue);
    });

    test('auxiliar cannot approve solicitud', () {
      final profile = user(role: UserRole.auxiliar, status: AccountStatus.active);
      expect(service.canApproveSolicitud(profile), isFalse);
    });

    test('admin can manage users', () {
      final profile = user(role: UserRole.admin, status: AccountStatus.active);
      expect(service.canManageUsers(profile), isTrue);
    });
  });
}
