import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/attendance/presentation/screens/attendance_confirmation_screen.dart';
import '../../features/attendance/presentation/screens/qr_scanner_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String attendanceScan = '/attendance/scan';
  static const String attendanceConfirm = '/attendance/confirm';
  static const String attendanceHistory = '/attendance/history';
  static const String adminDashboard = '/admin/dashboard';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(path: splash, name: 'splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: login, name: 'login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: register, name: 'register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: home, name: 'home', builder: (context, state) => const HomeScreen()),
      
      // QR Scanner route
      GoRoute(
        path: attendanceScan,
        name: 'attendanceScan',
        builder: (context, state) => const QRScannerScreen(),
      ),
      
      // Attendance Confirmation route (receives data via 'extra')
      GoRoute(
        path: attendanceConfirm,
        name: 'attendanceConfirm',
        builder: (context, state) {
          // Extract data passed from QR scanner
          final extra = state.extra as Map<String, dynamic>?;
          return AttendanceConfirmationScreen(
            siteId: extra?['siteId'] ?? 'unknown',
            siteName: extra?['siteName'] ?? 'Unknown Site',
          );
        },
      ),
      
      // Placeholder routes for future lessons
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Profile - Coming Soon'))),
      ),
      GoRoute(
        path: attendanceHistory,
        name: 'attendanceHistory',
        builder: (context, state) => const Scaffold(body: Center(child: Text('History - Coming Soon'))),
      ),
      GoRoute(
        path: adminDashboard,
        name: 'adminDashboard',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Admin Dashboard - Coming Soon'))),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri.path}')),
    ),
  );
}