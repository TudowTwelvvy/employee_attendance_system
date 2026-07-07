import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/responsive_sizes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../attendance/presentation/providers/sync_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final sizes = ResponsiveSizes(context);
    final isDesktop = sizes.isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRouter.login);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: sizes.centeredContent(
          child: SingleChildScrollView(
            // KEY FIX: Make it scrollable to prevent overflow
            child: Padding(
              padding: EdgeInsets.all(sizes.paddingHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Don't take extra space
                children: [
                  // Welcome message
                  Text(
                    'Welcome, ${user?.fullName ?? 'Employee'}!',
                    style: AppTheme.headingMedium(context),
                  ),
                  SizedBox(height: sizes.spaceSmall),
                  Text(
                    'Role: ${user?.role ?? 'Employee'}',
                    style: AppTheme.bodyLarge(context),
                  ),
                  SizedBox(height: sizes.spaceLarge),

                  // Sync banner (if pending)
                  const _SyncBanner(),
                  SizedBox(height: sizes.spaceMedium),

                  // Quick actions
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: isDesktop ? 20 : 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: sizes.spaceMedium),

                  // Responsive grid for action cards
                  if (isDesktop)
                    // Desktop: 2-column grid with Wrap
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: _buildActionCards(context, user),
                    )
                  else
                    // Mobile: vertical list
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildActionCards(context, user, isList: true),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds action cards based on user role
  List<Widget> _buildActionCards(
    BuildContext context,
    dynamic user, {
    bool isList = false,
  }) {
    final sizes = ResponsiveSizes(context);
    //final isDesktop = sizes.isDesktop;

    final cards = [
      _ActionCard(
        icon: Icons.qr_code_scanner,
        title: 'Scan QR Code',
        subtitle: 'Mark your attendance',
        onTap: () => context.push(AppRouter.attendanceScan),
      ),
      _ActionCard(
        icon: Icons.history,
        title: 'Attendance History',
        subtitle: 'View your past records',
        onTap: () => context.push(AppRouter.attendanceHistory),
      ),
      _ActionCard(
        icon: Icons.person,
        title: 'My Profile',
        subtitle: 'View and edit your details',
        onTap: () => context.push(AppRouter.profile),
      ),
    ];

    // Add admin card only for admins
    if (user?.isAdmin ?? false) {
      cards.add(
        _ActionCard(
          icon: Icons.admin_panel_settings,
          title: 'Admin Dashboard',
          subtitle: 'Manage employees, sites, and reports',
          onTap: () => context.push(AppRouter.adminDashboard),
        ),
      );
    }

    if (isList) {
      // Mobile: add spacing between cards
      final spacedCards = <Widget>[];
      for (int i = 0; i < cards.length; i++) {
        spacedCards.add(cards[i]);
        if (i < cards.length - 1) {
          spacedCards.add(SizedBox(height: 12.h));
        }
      }
      return spacedCards;
    }

    // Desktop: wrap in fixed-width containers
    return cards.map((card) {
      return SizedBox(width: (sizes.maxContentWidth - 48) / 2, child: card);
    }).toList();
  }
}

/// Sync banner widget
class _SyncBanner extends ConsumerWidget {
  const _SyncBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);
    final sizes = ResponsiveSizes(context);

    if (syncState.pendingCount == 0) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: sizes.spaceMedium),
      padding: EdgeInsets.all(sizes.cardPadding),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(sizes.borderRadius),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          Icon(
            Icons.sync_problem,
            color: Colors.orange,
            size: sizes.iconMedium,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${syncState.pendingCount} record(s) pending sync',
                  style: TextStyle(
                    fontSize: sizes.smallSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tap to sync now',
                  style: TextStyle(
                    fontSize: sizes.smallSize - 2,
                    color: Colors.orange.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          if (syncState.isSyncing)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.orange,
              ),
            )
          else
            IconButton(
              icon: Icon(
                Icons.sync,
                color: Colors.orange,
                size: sizes.iconMedium,
              ),
              onPressed: () {
                ref.read(syncProvider.notifier).syncNow();
              },
            ),
        ],
      ),
    );
  }
}

/// Action card widget
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = ResponsiveSizes(context);
    final isDesktop = sizes.isDesktop;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(sizes.borderRadius),
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 24 : 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(sizes.borderRadius),
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
              padding: EdgeInsets.all(isDesktop ? 16 : 12.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(sizes.borderRadius),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: isDesktop ? 32 : 28.r,
              ),
            ),
            SizedBox(width: isDesktop ? 20 : 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 6 : 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 14.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: isDesktop ? 18 : 16.r,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
