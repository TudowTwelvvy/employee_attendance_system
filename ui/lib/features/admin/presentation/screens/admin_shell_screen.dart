import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/responsive_scaffold.dart';

/// AdminShellScreen provides the navigation structure for admin pages. This is like the "frame" around all admin screens — it shows the side menu and the content area.
class AdminShellScreen extends StatefulWidget {
  final Widget child; // The current admin page content

  const AdminShellScreen({super.key, required this.child});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  // Determine current tab based on route
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location.contains('/admin/employees')) return 1;
    if (location.contains('/admin/sites')) return 2;
    if (location.contains('/admin/reports')) return 3;
    if (location.contains('/admin/qr')) return 4;
    return 0; // Dashboard
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Admin Dashboard',
      currentIndex: _getCurrentIndex(context),
      items: const [
        NavigationItem(
          label: 'Dashboard',
          route: '/admin/dashboard',
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
        ),
        NavigationItem(
          label: 'Employees',
          route: '/admin/employees',
          icon: Icons.people_outline,
          selectedIcon: Icons.people,
        ),
        NavigationItem(
          label: 'Sites',
          route: '/admin/sites',
          icon: Icons.location_on_outlined,
          selectedIcon: Icons.location_on,
        ),
        NavigationItem(
          label: 'Reports',
          route: '/admin/reports',
          icon: Icons.assessment_outlined,
          selectedIcon: Icons.assessment,
        ),
        NavigationItem(
          label: 'QR Codes',
          route: '/admin/qr',
          icon: Icons.qr_code_outlined,
          selectedIcon: Icons.qr_code,
        ),
      ],
      body: widget.child,
    );
  }
}
