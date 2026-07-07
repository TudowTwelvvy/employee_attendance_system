import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// ResponsiveScaffold adapts layout based on screen size.
///
/// On mobile: Bottom navigation bar
/// On desktop: Side navigation rail (left sidebar)
class ResponsiveScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int currentIndex;
  final List<NavigationItem> items;

  const ResponsiveScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.currentIndex,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // If width > 800, use desktop layout
    final isDesktop = screenWidth > 800;

    return Scaffold(
      appBar: isDesktop
          ? null // No app bar on desktop (title in rail)
          : AppBar(title: Text(title)),
      body: Row(
        children: [
          // Side rail for desktop
          if (isDesktop)
            NavigationRail(
              extended: screenWidth > 1200, // Show labels if wide enough
              minExtendedWidth: 200,
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                context.go(items[index].route);
              },
              destinations: items.map((item) {
                return NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: Text(item.label),
                );
              }).toList(),
            ),

          // Main content
          Expanded(child: body),
        ],
      ),
      // Bottom nav for mobile only
      bottomNavigationBar: isDesktop
          ? null
          : BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) {
                context.go(items[index].route);
              },
              items: items.map((item) {
                return BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  activeIcon: Icon(item.selectedIcon),
                  label: item.label,
                );
              }).toList(),
            ),
    );
  }
}

/// Data class for navigation items
class NavigationItem {
  final String label;
  final String route;
  final IconData icon;
  final IconData selectedIcon;

  const NavigationItem({
    required this.label,
    required this.route,
    required this.icon,
    required this.selectedIcon,
  });
}
