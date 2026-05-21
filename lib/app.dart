import 'package:flutter/material.dart';

import 'app_routes.dart';
import 'pages/blocked_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/pending_approval_page.dart';
import 'pages/splash_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario Lab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashPage(),
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.pendingApproval: (context) => const PendingApprovalPage(),
        AppRoutes.blocked: (context) => const BlockedPage(),
        AppRoutes.home: (context) => const HomePage(),
      },
    );
  }
}
