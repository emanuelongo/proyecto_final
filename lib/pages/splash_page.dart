import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

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
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final user = _authService.currentUser;
    if (user == null) {
      _goTo(AppRoutes.login);
      return;
    }

    try {
      final profile = await _profileService.fetchProfile(user.uid).timeout(
            const Duration(seconds: 10),
          );
      if (!mounted) {
        return;
      }
      if (profile == null) {
        setState(() {
          _loading = false;
          _error = 'Perfil no encontrado. Verifica Firestore.';
        });
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
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Error Firestore: ${error.code}';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'No se pudo cargar el perfil: $error';
      });
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
    return Scaffold(
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error ?? 'Error desconocido'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _bootstrap,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
      ),
    );
  }
}
