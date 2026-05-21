import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../models/enums.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/permission_service.dart';
import '../services/user_profile_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final UserProfileService _profileService = UserProfileService();
  final PermissionService _permissionService = const PermissionService();
  UserProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _authService.currentUser;
    if (user == null) {
      _goTo(AppRoutes.login);
      return;
    }

    final profile = await _profileService.fetchProfile(user.uid);
    if (!mounted) {
      return;
    }
    if (profile == null) {
      _goTo(AppRoutes.login);
      return;
    }

    switch (profile.status) {
      case AccountStatus.pendingApproval:
        _goTo(AppRoutes.pendingApproval);
        return;
      case AccountStatus.blocked:
        _goTo(AppRoutes.blocked);
        return;
      case AccountStatus.active:
        break;
    }

    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  void _goTo(String route) {
    if (!mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacementNamed(route);
    });
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (!mounted) {
      return;
    }
    _goTo(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profile = _profile;
    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text('Sin perfil activo.')),
      );
    }

    final canManageUsers = _permissionService.canManageUsers(profile);
    final canManageInventory = _permissionService.canManageInventory(profile);
    final canCreateSolicitud = _permissionService.canCreateSolicitud(profile);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario Laboratorio'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesion',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hola, ${profile.name}'),
            const SizedBox(height: 8),
            Text('Rol: ${profile.role.name}'),
            const SizedBox(height: 16),
            if (canManageInventory)
              ListTile(
                leading: const Icon(Icons.inventory),
                title: const Text('Gestion de inventario'),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.inventory),
              ),
            if (canManageInventory)
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Reportes de inventario'),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.reports),
              ),
            if (canCreateSolicitud)
              ListTile(
                leading: const Icon(Icons.assignment),
                title: const Text('Solicitudes'),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.solicitudes),
              ),
            if (canManageUsers)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Administracion de usuarios'),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.users),
              ),
          ],
        ),
      ),
    );
  }
}
