import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/core/theme/app_theme.dart';
import 'package:ui/features/admin/presentation/screens/dashboard_screen.dart';
import 'package:ui/features/auth/presentation/screens/register_screen.dart';
import 'package:ui/features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';


class AppRouter {
  
  AppRouter._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String attendanceScan = '/attendance/scan';
  static const String attendanceHistory = '/attendance/history';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminEmployees = '/admin/employees';

  //The router configuration
  //this is the "brain" of navigation it maps URLs to screens
  static final GoRouter router = GoRouter(
    // The initial route shown when app starts
    initialLocation: splash,
    
    // shows navigation in console (remove in production)
    debugLogDiagnostics: true,
    
    routes: [
      GoRoute(
        path: splash,           //the URL path: '/'
        name: 'splash',         //Named route for reference
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Login Screen
      GoRoute(
        path: login,            //The URL path: '/login'
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Register Screen
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Home Screen
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) =>  Scaffold(
          body:  Center(
            child: FloatingActionButton(
              onPressed: () {
                print('Scan QR!');
              },
              
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              
              // Shape options:
              shape: CircleBorder(),  // Circular (default)
              // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              
              child: const Icon(Icons.qr_code_scanner),
            ),
          )
        ),
      ),
      
      // Profile Screen
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Profile Screen - Coming Soon')),
        ),
      ),
      
      // Attendance Scan Screen
      GoRoute(
        path: attendanceScan,
        name: 'attendanceScan',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('QR Scanner - Coming Soon')),
        ),
      ),
      
      // Attendance History Screen
      GoRoute(
        path: attendanceHistory,
        name: 'attendanceHistory',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('History Screen - Coming Soon')),
        ),
      ),

      GoRoute(
        path: adminDashboard ,
        name: 'adminDashboard ',
        builder: (context, state) => const DashboardScreen(),
        ),
      
    ],
    
    // Error page - shown when URL doesn't match any route
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Text(
            'Page not found: ${state.uri.path}',
            style: const TextStyle(fontSize: 20),
          ),
        ),
      );
    },
  );
}