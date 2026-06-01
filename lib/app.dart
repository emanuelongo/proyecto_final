import 'package:flutter/material.dart';

import 'app_routes.dart';
import 'pages/blocked_page.dart';
import 'pages/home_page.dart';
import 'pages/inventory_page.dart';
import 'pages/login_page.dart';
import 'pages/pending_approval_page.dart';
import 'pages/solicitudes_page.dart';
import 'pages/splash_page.dart';
import 'pages/create_solicitud_page.dart';
import 'pages/insumo_detail_page.dart';
import 'pages/movement_page.dart';
import 'pages/movements_history_page.dart';
import 'pages/users_page.dart';
import 'pages/reports_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario Lab',
      debugShowCheckedModeBanner: false,
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
        AppRoutes.inventory: (context) => const InventoryPage(),
        AppRoutes.solicitudes: (context) => const SolicitudesPage(),
        AppRoutes.createSolicitud: (context) => const CreateSolicitudPage(),
        AppRoutes.movementsHistory: (context) => const MovementsHistoryPage(),
        AppRoutes.users: (context) => const UsersPage(),
        AppRoutes.reports: (context) => const ReportsPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.insumoDetail) {
          final args = settings.arguments;
          if (args is InsumoDetailArgs) {
            return MaterialPageRoute(
              builder: (_) => InsumoDetailPage(insumo: args.insumo),
            );
          }
        }
        if (settings.name == AppRoutes.movement) {
          final args = settings.arguments;
          if (args is MovementArgs) {
            return MaterialPageRoute(
              builder: (_) => MovementPage(insumo: args.insumo),
            );
          }
        }
        return null;
      },
    );
  }
}
