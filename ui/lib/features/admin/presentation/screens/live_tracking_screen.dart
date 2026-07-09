import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/responsive_sizes.dart';
import '../../data/datasources/mock_location_tracking_service.dart';
import '../../data/datasources/mock_site_service.dart';
import '../../data/models/employee_location_model.dart';
import '../../data/models/site_model.dart';

/// LiveTrackingScreen shows real-time employee locations on an interactive map.
class LiveTrackingScreen extends ConsumerStatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen> {
  final MapController _mapController = MapController();
  String? _selectedSiteId;
  List<EmployeeLocationModel> _locations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _loadLocations() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _locations = MockLocationTrackingService().getLiveLocations();
        _isLoading = false;
      });
    });
  }

  List<EmployeeLocationModel> get _filteredLocations {
    if (_selectedSiteId == null) return _locations;
    return _locations.where((l) => l.siteId == _selectedSiteId).toList();
  }

  List<SiteModel> get _sites => MockSiteService.getAllSites();

  @override
  Widget build(BuildContext context) {
    final sizes = ResponsiveSizes(context);
    final isDesktop = sizes.isDesktop;

    return Scaffold(
      body: SafeArea(
        child: isDesktop
            ? _buildDesktopLayout(sizes)
            : _buildMobileLayout(sizes),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadLocations,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildDesktopLayout(ResponsiveSizes sizes) {
    return Row(
      children: [
        Expanded(flex: 3, child: _buildMap()),
        SizedBox(width: 350, child: _buildSidebar(sizes, true)),
      ],
    );
  }

  Widget _buildMobileLayout(ResponsiveSizes sizes) {
    return Stack(children: [_buildMap(), _buildMobileBottomSheet(sizes)]);
  }

  Widget _buildMobileBottomSheet(ResponsiveSizes sizes) {
    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.10,
      maxChildSize: 0.60,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(child: _buildEmployeeList(scrollController, false)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMap() {
    final sites = _sites;
    final center = sites.isNotEmpty
        ? LatLng(sites[0].latitude, sites[0].longitude)
        : const LatLng(-25.7479, 28.2293);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 13,
        minZoom: 5,
        maxZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.yourcompany.attendanceapp',
        ),
        _buildSiteCircles(),
        _buildEmployeeMarkers(),
      ],
    );
  }

  Widget _buildSiteCircles() {
    return CircleLayer(
      circles: _sites.map((site) {
        return CircleMarker(
          point: LatLng(site.latitude, site.longitude),
          radius: site.radiusInMeters.toDouble(),
          useRadiusInMeter: true,
          color: Colors.blue.withOpacity(0.1),
          borderColor: Colors.blue,
          borderStrokeWidth: 2,
        );
      }).toList(),
    );
  }

  Widget _buildEmployeeMarkers() {
    return MarkerLayer(
      markers: _filteredLocations.map((location) {
        return Marker(
          point: LatLng(location.latitude, location.longitude),
          width: 40,
          height: 40,
          child: _buildEmployeePin(location),
        );
      }).toList(),
    );
  }

  Widget _buildEmployeePin(EmployeeLocationModel location) {
    final isActive = location.isRecent && location.isCheckedIn;
    final color = isActive ? Colors.green : Colors.grey;

    return GestureDetector(
      onTap: () => _showEmployeeDetails(location),
      child: Tooltip(
        message:
            '${location.employeeName}\n${location.siteName}\n${location.timeAgo}',
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              location.employeeName[0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEmployeeDetails(EmployeeLocationModel location) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: location.isRecent
                        ? Colors.green
                        : Colors.grey,
                    child: Text(
                      location.employeeName[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.employeeName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          location.siteName,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Status', location.status.toUpperCase()),
              _buildDetailRow('Last Updated', location.timeAgo),
              _buildDetailRow('Device', location.deviceName ?? 'Unknown'),
              _buildDetailRow(
                'Coordinates',
                '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(ResponsiveSizes sizes, bool isDesktop) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(sizes.paddingHorizontal),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Live Tracking', style: AppTheme.headingMedium(context)),
                SizedBox(height: sizes.spaceSmall),
                Text(
                  '${_filteredLocations.length} employees online',
                  style: AppTheme.bodyLarge(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(sizes.paddingHorizontal),
            child: DropdownButtonFormField<String?>(
              value: _selectedSiteId,
              decoration: InputDecoration(
                labelText: 'Filter by Site',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.filter_list),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All Sites'),
                ),
                ..._sites.map((site) {
                  return DropdownMenuItem<String?>(
                    value: site.id,
                    child: Text(site.name),
                  );
                }).toList(),
              ],
              onChanged: (value) => setState(() => _selectedSiteId = value),
            ),
          ),
          Divider(height: 1),
          Expanded(child: _buildEmployeeList(null, isDesktop)),
        ],
      ),
    );
  }

  Widget _buildEmployeeList(
    ScrollController? scrollController,
    bool isDesktop,
  ) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_filteredLocations.isEmpty) {
      return const Center(child: Text('No employees found for selected site'));
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: _filteredLocations.length,
      itemBuilder: (context, index) {
        return _buildEmployeeListTile(_filteredLocations[index], isDesktop);
      },
    );
  }

  Widget _buildEmployeeListTile(
    EmployeeLocationModel location,
    bool isDesktop,
  ) {
    final isActive = location.isRecent && location.isCheckedIn;

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: isActive ? Colors.green : Colors.grey,
            child: Text(
              location.employeeName[0],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isActive ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        location.employeeName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${location.siteName} • ${location.timeAgo}',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: Chip(
        label: Text(
          location.status.replaceAll('_', ' ').toUpperCase(),
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
        backgroundColor: isActive ? Colors.green : Colors.grey,
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onTap: () => _mapController.move(
        LatLng(location.latitude, location.longitude),
        16,
      ),
    );
  }
}
