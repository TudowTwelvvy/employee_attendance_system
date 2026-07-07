import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state to get current user
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // If no user is logged in, show error
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('No user logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          // Settings icon
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // open settings
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile avatar and name section
              _ProfileHeader(user: user),
              SizedBox(height: 32.h),

              // Account details card
              _AccountDetailsCard(user: user),
              SizedBox(height: 32.h),

              // Role information card
              _RoleInfoCard(role: user.role),
              SizedBox(height: 32.h),

              // Logout button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton.icon(
                  onPressed: () => _logout(context, ref),
                  icon: const Icon(Icons.logout),
                  label: const Text('LOGOUT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handles logout with confirmation dialog
  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    // If user confirmed, perform logout
    if (shouldLogout == true) {
      await ref.read(authProvider.notifier).logout();

      // Navigate to login screen
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
}

/// Profile header with avatar, name, and role badge
class _ProfileHeader extends StatelessWidget {
  final dynamic user; // UserEntity

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    // Get first letter of name for avatar
    final initial = user.fullName.isNotEmpty
        ? user.fullName[0].toUpperCase()
        : '?';

    // Role color mapping
    final roleColor = _getRoleColor(user.role);
    final roleIcon = _getRoleIcon(user.role);

    return Column(
      children: [
        // Avatar circle
        Container(
          width: 100.r,
          height: 100.r,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 40.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // Full name
        Text(
          user.fullName,
          style: AppTheme.headingMedium(context),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),

        // Email
        Text(
          user.email,
          style: AppTheme.bodyLarge(context),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12.h),

        // Role badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: roleColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: roleColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(roleIcon, size: 16.r, color: roleColor),
              SizedBox(width: 6.w),
              Text(
                user.role,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: roleColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Returns color based on role
  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return Colors.green;
      case 'Manager':
        return Colors.orange;
      case 'Employee':
      default:
        return AppTheme.primaryColor;
    }
  }

  /// Returns icon based on role
  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'Admin':
        return Icons.admin_panel_settings;
      case 'Manager':
        return Icons.manage_accounts;
      case 'Employee':
      default:
        return Icons.person;
    }
  }
}

/// Card showing account details
class _AccountDetailsCard extends StatelessWidget {
  final dynamic user; // UserEntity

  const _AccountDetailsCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
          Text(
            'Account Details',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _DetailRow(icon: Icons.badge, label: 'User ID', value: user.id),
          Divider(height: 24.h),
          _DetailRow(icon: Icons.email, label: 'Email', value: user.email),
          Divider(height: 24.h),
          _DetailRow(
            icon: Icons.person,
            label: 'Full Name',
            value: user.fullName,
          ),
          Divider(height: 24.h),
          _DetailRow(icon: Icons.work, label: 'Role', value: user.role),
        ],
      ),
    );
  }
}

/// Card showing role permissions
class _RoleInfoCard extends StatelessWidget {
  final String role;

  const _RoleInfoCard({required this.role});

  @override
  Widget build(BuildContext context) {
    // Get permissions based on role
    final permissions = _getPermissions(role);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
          Text(
            'Your Permissions',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          ...permissions.map(
            (permission) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 20.r, color: Colors.green),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      permission,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns list of permissions based on role
  List<String> _getPermissions(String role) {
    switch (role) {
      case 'Admin':
        return [
          'Manage employees',
          'Manage work sites',
          'Generate QR codes',
          'View all attendance reports',
          'View attendance locations on map',
          'Mark own attendance',
        ];
      case 'Manager':
        return [
          'View team attendance reports',
          'View attendance locations',
          'Mark own attendance',
          'View employee profiles',
        ];
      case 'Employee':
      default:
        return [
          'Mark attendance via QR scan',
          'View own attendance history',
          'View own profile',
          'Update personal information',
        ];
    }
  }
}

/// Reusable row for detail items
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.r, color: AppTheme.primaryColor),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
