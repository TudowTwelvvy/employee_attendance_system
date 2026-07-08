import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/responsive_sizes.dart';
import '../../data/datasources/mock_site_service.dart';
import '../../data/models/site_model.dart';

class SiteManagementScreen extends ConsumerStatefulWidget {
  const SiteManagementScreen({super.key});

  @override
  ConsumerState<SiteManagementScreen> createState() =>
      _SiteManagementScreenState();
}

class _SiteManagementScreenState extends ConsumerState<SiteManagementScreen> {
  String? _selectedSiteId;

  @override
  Widget build(BuildContext context) {
    final sizes = ResponsiveSizes(context);
    final isDesktop = sizes.isDesktop;
    final sites = MockSiteService.getAllSites();

    return Scaffold(
      body: SafeArea(
        child: isDesktop
            ? _buildDesktopLayout(sites, sizes)
            : _buildMobileLayout(sites, sizes),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Future: add new site
          _showComingSoon();
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add_location),
      ),
    );
  }

  // Desktop: side-by-side layout (list + detail)
  Widget _buildDesktopLayout(List<SiteModel> sites, ResponsiveSizes sizes) {
    return sizes.centeredContent(
      child: Padding(
        padding: EdgeInsets.all(sizes.paddingHorizontal),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Site list
            SizedBox(
              width: 350,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Work Sites', style: AppTheme.headingMedium(context)),
                  SizedBox(height: sizes.spaceSmall),
                  Text(
                    "Manage your organization's locations",
                    style: AppTheme.bodyLarge(context),
                  ),
                  SizedBox(height: sizes.spaceLarge),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sites.length,
                      itemBuilder: (context, index) {
                        return _SiteListItem(
                          site: sites[index],
                          isSelected: sites[index].id == _selectedSiteId,
                          onTap: () {
                            setState(() {
                              _selectedSiteId = sites[index].id;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 24),
            // Right: Site detail — WRAP IN Expanded + SingleChildScrollView
            Expanded(child: SingleChildScrollView(child: _buildDetailPanel())),
          ],
        ),
      ),
    );
  }

  // Mobile: scrollable list with expandable cards
  Widget _buildMobileLayout(List<SiteModel> sites, ResponsiveSizes sizes) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(sizes.paddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Work Sites', style: AppTheme.headingMedium(context)),
            SizedBox(height: sizes.spaceSmall),
            Text(
              "Manage your organization's locations",
              style: AppTheme.bodyLarge(context),
            ),
            SizedBox(height: sizes.spaceLarge),
            ...sites.map((site) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _SiteDetailCard(site: site, isDesktop: false),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// Builds the detail panel based on selected site
  /// If site selected, look it up and handle "not found" gracefully.
  Widget _buildDetailPanel() {
    // No site selected yet
    if (_selectedSiteId == null) {
      return _buildEmptyDetail();
    }

    // Look up the selected site
    final site = MockSiteService.getSiteById(_selectedSiteId!);

    // If site is null, show empty state (or error)
    if (site == null) {
      return _buildEmptyDetail(message: 'Site not found');
    }

    // Site found — show detail card
    return _buildSiteDetail(site, true);
  }

  Widget _buildEmptyDetail({String message = 'Select a site to view details'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSiteDetail(SiteModel site, bool isDesktop) {
    return _SiteDetailCard(site: site, isDesktop: isDesktop);
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming in a future lesson! 🚀'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Site list item for desktop sidebar
class _SiteListItem extends StatelessWidget {
  final SiteModel site;
  final bool isSelected;
  final VoidCallback onTap;

  const _SiteListItem({
    required this.site,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: site.isActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.location_on,
                color: site.isActive ? Colors.green : Colors.grey,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    site.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.primaryColor : null,
                    ),
                  ),
                  Text(
                    site.address,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Site detail card showing map, info, and QR code
class _SiteDetailCard extends StatelessWidget {
  final SiteModel site;
  final bool isDesktop;

  const _SiteDetailCard({required this.site, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: isDesktop ? 300 : 200.h,
              width: double.infinity,
              color: Colors.grey[200],
              child: Image.network(
                site.staticMapUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Map preview unavailable',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Site info
          Padding(
            padding: EdgeInsets.all(isDesktop ? 24 : 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        site.name,
                        style: TextStyle(
                          fontSize: isDesktop ? 24 : 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: site.isActive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        site.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: site.isActive ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isDesktop ? 8 : 8.h),
                Text(
                  site.address,
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14.sp,
                    color: Colors.grey,
                  ),
                ),
                if (site.description != null) ...[
                  SizedBox(height: isDesktop ? 8 : 8.h),
                  Text(
                    site.description!,
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                SizedBox(height: isDesktop ? 24 : 16.h),

                // Details grid
                _buildDetailRow(
                  icon: Icons.gps_fixed,
                  label: 'Coordinates',
                  value: site.formattedCoordinates,
                ),
                SizedBox(height: isDesktop ? 12 : 8.h),
                _buildDetailRow(
                  icon: Icons.radar,
                  label: 'Geofence Radius',
                  value: '${site.radiusInMeters} meters',
                ),
                SizedBox(height: isDesktop ? 12 : 8.h),
                _buildDetailRow(
                  icon: Icons.qr_code,
                  label: 'QR Code',
                  value: site.qrCodeValue,
                ),
                SizedBox(height: isDesktop ? 24 : 16.h),

                // QR code display
                Container(
                  padding: EdgeInsets.all(isDesktop ? 16 : 12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.qr_code_2,
                        size: isDesktop ? 48 : 40.r,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(width: isDesktop ? 16 : 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scan Code',
                              style: TextStyle(
                                fontSize: isDesktop ? 14 : 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              site.qrCodeValue,
                              style: TextStyle(
                                fontSize: isDesktop ? 18 : 16.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy, color: Colors.grey),
                        onPressed: () {
                          // Future: copy to clipboard
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text(
                value,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
