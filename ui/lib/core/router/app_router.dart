import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/features/admin/presentation/screens/attendance_reports_screen.dart';
import 'package:ui/features/admin/presentation/screens/dashboard_screen.dart';
import 'package:ui/features/admin/presentation/screens/employee_management_screen.dart';
import 'package:ui/features/admin/presentation/screens/site_management_screen.dart';
import 'package:ui/features/attendance/presentation/screens/attendance_confirmation_screen.dart';
import 'package:ui/features/attendance/presentation/screens/attendance_history_screen.dart';
import 'package:ui/features/attendance/presentation/screens/qr_scanner_screen.dart';
import 'package:ui/features/auth/presentation/screens/login_screen.dart';
import 'package:ui/features/auth/presentation/screens/register_screen.dart';
import 'package:ui/features/auth/presentation/screens/splash_screen.dart';
import 'package:ui/features/home/presentation/screens/home_screen.dart';
import 'package:ui/features/profile/presentation/screens/profile_screen.dart';
import '../../features/admin/presentation/screens/admin_shell_screen.dart';
import '../../features/admin/presentation/screens/qr_generation_screen.dart';

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

  // Admin routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminEmployees = '/admin/employees';
  static const String adminSites = '/admin/sites';
  static const String adminReports = '/admin/reports';
  static const String adminQR = '/admin/qr';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    routes: [
      //Mobile routes
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: attendanceScan,
        name: 'attendanceScan',
        builder: (context, state) => const QRScannerScreen(),
      ),
      GoRoute(
        path: attendanceConfirm,
        name: 'attendanceConfirm',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AttendanceConfirmationScreen(
            siteId: extra?['siteId'] ?? 'unknown',
            siteName: extra?['siteName'] ?? 'Unknown Site',
            siteLatitude: extra?['latitude'] ?? 0.0,
            siteLongitude: extra?['longitude'] ?? 0.0,
            radiusInMeters: extra?['radiusInMeters'] ?? 100.0,
          );
        },
      ),
      GoRoute(
        path: attendanceHistory,
        name: 'attendanceHistory',
        builder: (context, state) => const AttendanceHistoryScreen(),
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Admin routes with ShellRoute (nested navigation)
      ShellRoute(
        builder: (context, state, child) {
          return AdminShellScreen(child: child);
        },
        routes: [
          GoRoute(
            path: adminDashboard,
            name: 'adminDashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: adminEmployees,
            name: 'adminEmployees',
            builder: (context, state) => const EmployeeManagementScreen(),
          ),
          GoRoute(
            path: adminSites,
            name: 'adminSites',
            builder: (context, state) => const SiteManagementScreen(),
          ),
          GoRoute(
            path: adminReports,
            name: 'adminReports',
            builder: (context, state) => const AttendanceReportsScreen(),
          ),
          GoRoute(
            path: adminQR,
            name: 'adminQR',
            builder: (context, state) => const QRGenerationScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri.path}')),
    ),
  );
}
