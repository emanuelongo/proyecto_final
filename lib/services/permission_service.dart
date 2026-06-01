import '../models/enums.dart';
import '../models/user_profile.dart';

class PermissionService {
  const PermissionService();

  bool canAccessModule(UserProfile user) {
    return user.status == AccountStatus.active;
  }

  bool canCreateSolicitud(UserProfile user) {
    return canAccessModule(user) && user.role == UserRole.auxiliar;
  }

  bool canApproveSolicitud(UserProfile user) {
    return canAccessModule(user) && user.role == UserRole.docente;
  }

  bool canRejectSolicitud(UserProfile user) {
    return canApproveSolicitud(user);
  }

  bool canManageUsers(UserProfile user) {
    return canAccessModule(user) && user.role == UserRole.admin;
  }

  bool canManageInventory(UserProfile user) {
    return canAccessModule(user) &&
        (user.role == UserRole.auxiliar || user.role == UserRole.admin || user.role == UserRole.docente);
  }

  bool canRegisterMovement(UserProfile user) {
    return canAccessModule(user) && user.role == UserRole.auxiliar;
  }

  bool canViewSolicitudes(UserProfile user) {
    return canAccessModule(user);
  }

  bool canViewMovements(UserProfile user) {
    return canAccessModule(user);
  }

  bool canViewReports(UserProfile user) {
    return canAccessModule(user) &&
        (user.role == UserRole.docente || user.role == UserRole.admin);
  }
}
