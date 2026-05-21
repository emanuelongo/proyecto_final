import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../models/enums.dart';
import '../services/auth_service.dart';
import '../services/user_profile_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final AuthService _authService = AuthService();
  final UserProfileService _profileService = UserProfileService();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
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
        break;
      case AccountStatus.blocked:
        _goTo(AppRoutes.blocked);
        break;
      case AccountStatus.active:
        _goTo(AppRoutes.home);
        break;
    }
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

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
