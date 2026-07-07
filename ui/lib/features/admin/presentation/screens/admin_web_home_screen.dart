import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/features/admin/presentation/screens/dashboard_screen.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
//import 'admin_dashboard_screen.dart';

class AdminWebHomeScreen extends ConsumerWidget {
  const AdminWebHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    //only admins
    if (user == null || !user.isAdmin) {
      return const _AccessDeniedWebScreen();
    }

    return ResponsiveLayout(
      // Mobile... bottom navigation
      mobile: _MobileAdminLayout(user: user),
      // Desktop... sidebar navigation
      desktop: _DesktopAdminLayout(user: user),
    );
  }
}

/// Desktop layout with sidebar
class _DesktopAdminLayout extends StatefulWidget {
  final dynamic user;
  const _DesktopAdminLayout({required this.user});

  @override
  State<_DesktopAdminLayout> createState() => _DesktopAdminLayoutState();
}

class _DesktopAdminLayoutState extends State<_DesktopAdminLayout> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.dashboard,
      label: 'Dashboard',
      screen: const AdminDashboardScreen(),
    ),
    _NavItem(
      icon: Icons.people,
      label: 'Employees',
      screen: const _PlaceholderScreen('Employees'),
    ),
    _NavItem(
      icon: Icons.location_on,
      label: 'Sites',
      screen: const _PlaceholderScreen('Sites'),
    ),
    _NavItem(
      icon: Icons.qr_code,
      label: 'QR Codes',
      screen: const _PlaceholderScreen('QR Codes'),
    ),
    _NavItem(
      icon: Icons.assessment,
      label: 'Reports',
      screen: const _PlaceholderScreen('Reports'),
    ),
    _NavItem(
      icon: Icons.map,
      label: 'Tracking',
      screen: const _PlaceholderScreen('Live Tracking'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            color: Colors.white,
            child: Column(
              children: [
                // Logo
                Image.asset(
                  'assets/images/TraBSLogo.png',
                  height: 150.h,
                  width: 150.w,
                  fit: BoxFit.contain,
                ),

                Container(
                  padding: EdgeInsets.all(24.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        color: AppTheme.primaryColor,
                        size: 32,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Admin Panel',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                // Navigation items
                Expanded(
                  child: ListView.builder(
                    itemCount: _navItems.length,
                    itemBuilder: (context, index) {
                      final item = _navItems[index];
                      final isSelected = index == _selectedIndex;
                      return ListTile(
                        leading: Icon(
                          item.icon,
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey,
                        ),
                        title: Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onTap: () => setState(() => _selectedIndex = index),
                      );
                    },
                  ),
                ),
                // User info at bottom
                Divider(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      widget.user.fullName[0].toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(widget.user.fullName),
                  subtitle: Text(widget.user.email),
                  trailing: IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => _logout(context),
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Container(
              color: Color(0xFFF8F9FA),
              child: _navItems[_selectedIndex].screen,
            ),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    context.go('/login');
  }
}

/// Mobile layout with bottom navigation
class _MobileAdminLayout extends StatefulWidget {
  final dynamic user;
  const _MobileAdminLayout({required this.user});

  @override
  State<_MobileAdminLayout> createState() => _MobileAdminLayoutState();
}

class _MobileAdminLayoutState extends State<_MobileAdminLayout> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.dashboard,
      label: 'Dashboard',
      screen: const AdminDashboardScreen(),
    ),
    _NavItem(
      icon: Icons.people,
      label: 'Employees',
      screen: const _PlaceholderScreen('Employees'),
    ),
    _NavItem(
      icon: Icons.assessment,
      label: 'Reports',
      screen: const _PlaceholderScreen('Reports'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _navItems[_selectedIndex].screen,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: _navItems
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }

  void _logout(BuildContext context) {
    context.go('/login');
  }
}

/// Navigation item data class
class _NavItem {
  final IconData icon;
  final String label;
  final Widget screen;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}

/// Placeholder for screens not yet built
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen(this.title);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '$title — Coming Soon',
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// Web access denied screen
class _AccessDeniedWebScreen extends StatelessWidget {
  const _AccessDeniedWebScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 80, color: Colors.red),
            SizedBox(height: 24),
            Text(
              'Access Denied',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'You do not have admin privileges.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('GO TO HOME'),
            ),
          ],
        ),
      ),
    );
  }
}
