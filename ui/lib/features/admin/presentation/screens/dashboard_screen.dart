import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state to get current user
    final authState = ref.watch(authProvider);
    final user = authState.user;

    //If no user or not admin, show access denied
    if (user == null || !user.isAdmin) {
      return _AccessDeniedScreen();
    }

    // Mock statistics (will be real data from API in future)
    final stats = _MockAdminStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          // Settings icon
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Future: admin settings
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              _AdminHeader(userName: user.fullName),
              SizedBox(height: 24.h),

              // Statistics cards row
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.people,
                      title: 'Employees',
                      value: stats.totalEmployees.toString(),
                      color: Colors.blue,
                      onTap: () {
                        // Future: navigate to employee management
                        _showComingSoon(context);
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.location_on,
                      title: 'Sites',
                      value: stats.totalSites.toString(),
                      color: Colors.green,
                      onTap: () {
                        _showComingSoon(context);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle,
                      title: 'Today\'s Check-ins',
                      value: stats.todayCheckIns.toString(),
                      color: Colors.orange,
                      onTap: () {
                        _showComingSoon(context);
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.qr_code,
                      title: 'QR Codes',
                      value: stats.totalQRCodes.toString(),
                      color: Colors.purple,
                      onTap: () {
                        _showComingSoon(context);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Quick actions section
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),

              _ActionListTile(
                icon: Icons.person_add,
                title: 'Add Employee',
                subtitle: 'Register a new employee',
                color: Colors.blue,
                onTap: () => _showComingSoon(context),
              ),
              SizedBox(height: 8.h),

              _ActionListTile(
                icon: Icons.add_location,
                title: 'Add Work Site',
                subtitle: 'Create a new work location',
                color: Colors.green,
                onTap: () => _showComingSoon(context),
              ),
              SizedBox(height: 8.h),

              _ActionListTile(
                icon: Icons.qr_code_2,
                title: 'Generate QR Code',
                subtitle: 'Create QR code for a site',
                color: Colors.purple,
                onTap: () => _showComingSoon(context),
              ),
              SizedBox(height: 8.h),

              _ActionListTile(
                icon: Icons.assessment,
                title: 'View Reports',
                subtitle: 'Attendance reports and analytics',
                color: Colors.orange,
                onTap: () => _showComingSoon(context),
              ),
              SizedBox(height: 8.h),

              _ActionListTile(
                icon: Icons.map,
                title: 'Live Tracking',
                subtitle: 'View employee locations on map',
                color: Colors.red,
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming in a future! '),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Screen shown when non-admin tries to access admin area
class _AccessDeniedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Access Denied')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 80.r, color: Colors.red),
              SizedBox(height: 24.h),
              Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'You do not have permission to access the admin dashboard.\n\n'
                'This area is restricted to administrators only.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('GO TO HOME'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Welcome header with admin badge
class _AdminHeader extends StatelessWidget {
  final String userName;

  const _AdminHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 32.w : 20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 16.r,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'ADMIN PORTAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Welcome back, $userName!',
            style: TextStyle(
              fontSize: isDesktop ? 28.sp : 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Here\'s what\'s happening in your organization today.',
            style: TextStyle(
              fontSize: isDesktop ? 16.sp : 14.sp,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Statistics card widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: color, size: 24.r),
            ),
            SizedBox(height: 12.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// Action list tile widget
class _ActionListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 28.r),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.r, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

/// Mock statistics for admin dashboard
class _MockAdminStats {
  final int totalEmployees = 24;
  final int totalSites = 5;
  final int todayCheckIns = 18;
  final int totalQRCodes = 12;
}
