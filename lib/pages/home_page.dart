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

  static const Color primaryPurple = Color(0xFF8F5DFA);
  static const Color accentGreen = Color(0xFFB0FA5D);

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
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final profile = _profile;

    if (profile == null) {
      return const Scaffold(
        body: Center(
          child: Text('Sin perfil activo.'),
        ),
      );
    }

    final canManageUsers = _permissionService.canManageUsers(profile);
    final canManageInventory = _permissionService.canManageInventory(profile);
    final canViewSolicitudes = _permissionService.canViewSolicitudes(profile);
    final canViewReports = _permissionService.canViewReports(profile);
    final canViewMovements = _permissionService.canViewMovements(profile);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: const Text(
          'GoLab',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryPurple,
                      Color(0xFF7B4FE0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, ${profile.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accentGreen,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        profile.role.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Módulos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              if (canManageInventory)
                _MenuCard(
                  icon: Icons.inventory_2_outlined,
                  title: 'Gestión de inventario',
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppRoutes.inventory),
                ),

              if (canViewMovements)
                _MenuCard(
                  icon: Icons.swap_horiz_rounded,
                  title: 'Movimientos',
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppRoutes.movementsHistory),
                ),

              if (canViewReports)
                _MenuCard(
                  icon: Icons.bar_chart_rounded,
                  title: 'Reportes',
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppRoutes.reports),
                ),

              if (canViewSolicitudes)
                _MenuCard(
                  icon: Icons.assignment_outlined,
                  title: 'Solicitudes',
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppRoutes.solicitudes),
                ),

              if (canManageUsers)
                _MenuCard(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Administración de usuarios',
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppRoutes.users),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  static const Color primaryPurple = Color(0xFF8F5DFA);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: primaryPurple.withOpacity(.15),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryPurple.withOpacity(.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: primaryPurple,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
