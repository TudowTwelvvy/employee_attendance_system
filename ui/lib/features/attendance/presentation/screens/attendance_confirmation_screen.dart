import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/core/services/connectivity_service.dart';
//import 'package:ui/core/services/offline_queue_service.dart';
import 'package:ui/features/attendance/presentation/providers/sync_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/mock_attendance_service.dart';
import '../../data/models/attendance_record_model.dart';
import '../providers/device_info_provider.dart';
import '../providers/location_provider.dart';

class AttendanceConfirmationScreen extends ConsumerStatefulWidget {
  final String siteId;
  final String siteName;
  final double siteLatitude;
  final double siteLongitude;
  final double radiusInMeters;

  const AttendanceConfirmationScreen({
    super.key,
    required this.siteId,
    required this.siteName,
    required this.siteLatitude,
    required this.siteLongitude,
    required this.radiusInMeters,
  });

  @override
  ConsumerState<AttendanceConfirmationScreen> createState() =>
      _AttendanceConfirmationScreenState();
}

class _AttendanceConfirmationScreenState
    extends ConsumerState<AttendanceConfirmationScreen> {
  @override
  void initState() {
    super.initState();

    // Wait for first frame to complete before calling providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get GPS location as soon as screen opens
      ref
          .read(locationProvider.notifier)
          .getLocationAndValidate(
            siteLatitude: widget.siteLatitude,
            siteLongitude: widget.siteLongitude,
            radiusInMeters: widget.radiusInMeters,
          );

      // Get device info
      ref.read(deviceInfoProvider.notifier).loadDeviceInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch states for UI updates
    final locationState = ref.watch(locationProvider);
    final deviceState = ref.watch(deviceInfoProvider);

    // Format current date and time
    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final dateString = '${now.day}/${now.month}/${now.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Attendance')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success icon
              Icon(Icons.check_circle, size: 80.r, color: Colors.green),
              SizedBox(height: 16.h),

              // Title
              Text(
                'Attendance Check-In',
                style: AppTheme.headingMedium(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              // Site info card
              _InfoCard(
                title: 'Work Site',
                icon: Icons.location_on,
                children: [
                  _InfoRow(label: 'Site Name', value: widget.siteName),
                  _InfoRow(label: 'Site ID', value: widget.siteId),
                  _InfoRow(
                    label: 'Allowed Radius',
                    value: '${widget.radiusInMeters}m',
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Date and Time card
              _InfoCard(
                title: 'Date & Time',
                icon: Icons.access_time,
                children: [
                  _InfoRow(label: 'Date', value: dateString),
                  _InfoRow(label: 'Time', value: timeString),
                ],
              ),
              SizedBox(height: 16.h),

              // GPS Location — REAL DATA
              _InfoCard(
                title: 'GPS Location',
                icon: Icons.gps_fixed,
                children: [
                  if (locationState.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (locationState.errorMessage != null)
                    Text(
                      locationState.errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 14.sp),
                    )
                  else if (locationState.position != null) ...[
                    // Real coordinates
                    _InfoRow(
                      label: 'Your Latitude',
                      value:
                          '${locationState.position!.latitude.toStringAsFixed(6)}°',
                    ),
                    _InfoRow(
                      label: 'Your Longitude',
                      value:
                          '${locationState.position!.longitude.toStringAsFixed(6)}°',
                    ),
                    _InfoRow(
                      label: 'Accuracy',
                      value:
                          '${locationState.position!.accuracy.toStringAsFixed(1)} meters',
                    ),
                    _InfoRow(
                      label: 'Distance from Site',
                      value: locationState.distanceFromSite != null
                          ? '${locationState.distanceFromSite!.toStringAsFixed(1)} meters'
                          : 'Unknown',
                    ),
                    SizedBox(height: 8.h),

                    // Geofence status banner
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: locationState.isWithinGeofence
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: locationState.isWithinGeofence
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            locationState.isWithinGeofence
                                ? Icons.check_circle
                                : Icons.error,
                            color: locationState.isWithinGeofence
                                ? Colors.green
                                : Colors.red,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              locationState.isWithinGeofence
                                  ? 'Within geofence — You are at the site!'
                                  : 'Outside geofence — You are too far from the site!',
                              style: TextStyle(
                                color: locationState.isWithinGeofence
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    const _InfoRow(
                      label: 'Status',
                      value: 'Location unavailable',
                    ),
                ],
              ),
              SizedBox(height: 16.h),

              // Device Information with real data
              _InfoCard(
                title: 'Device Information',
                icon: Icons.phone_android,
                children: [
                  if (deviceState.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (deviceState.errorMessage != null)
                    Text(
                      deviceState.errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 14.sp),
                    )
                  else if (deviceState.deviceInfo != null) ...[
                    _InfoRow(
                      label: 'Device',
                      value: deviceState.deviceInfo!.deviceName,
                    ),
                    _InfoRow(
                      label: 'Model',
                      value: deviceState.deviceInfo!.deviceModel,
                    ),
                    _InfoRow(
                      label: 'OS',
                      value:
                          '${deviceState.deviceInfo!.operatingSystem} ${deviceState.deviceInfo!.osVersion}',
                    ),
                    _InfoRow(
                      label: 'App Version',
                      value: deviceState.deviceInfo!.appVersion,
                    ),
                  ] else
                    const _InfoRow(
                      label: 'Status',
                      value: 'Unable to read device info',
                    ),
                ],
              ),
              SizedBox(height: 32.h),

              // Submit button... ONLY enabled if within geofence!
              SizedBox(
                height: 50.h,
                child: ElevatedButton.icon(
                  onPressed: locationState.isWithinGeofence
                      ? () => _submitAttendance(context)
                      : null, // Disabled if outside geofence
                  icon: const Icon(Icons.check),
                  label: const Text('CONFIRM CHECK-IN'),
                ),
              ),
              SizedBox(height: 12.h),

              // Cancel button
              SizedBox(
                height: 50.h,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('CANCEL'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Submits attendance to the mock service
  Future<void> _submitAttendance(BuildContext context) async {
    final locationState = ref.read(locationProvider);
    final deviceState = ref.read(deviceInfoProvider);
    final authState = ref.read(authProvider);

    // Validate data
    if (locationState.position == null) {
      _showError(context, 'Location not available. Please try again.');
      return;
    }

    if (deviceState.deviceInfo == null) {
      _showError(context, 'Device info not available. Please try again.');
      return;
    }

    // Create the attendance record
    final record = AttendanceRecordModel(
      employeeId: authState.user?.id ?? 'unknown',
      employeeName: authState.user?.fullName ?? 'Unknown',
      siteId: widget.siteId,
      siteName: widget.siteName,
      qrCodeValue: widget.siteId,
      latitude: locationState.position!.latitude,
      longitude: locationState.position!.longitude,
      deviceName: deviceState.deviceInfo!.deviceName,
      deviceModel: deviceState.deviceInfo!.deviceModel,
      operatingSystem:
          '${deviceState.deviceInfo!.operatingSystem} ${deviceState.deviceInfo!.osVersion}',
      appVersion: deviceState.deviceInfo!.appVersion,
      scanTime: DateTime.now(),
    );

    // Check internet connection
    final isOnline = await ConnectivityService().isConnected();

    if (isOnline) {
      // Online: submit directly
      _showLoading(context);
      final success = await MockAttendanceService.submitAttendance(record);
      if (mounted) Navigator.pop(context); // Close loading

      if (success && mounted) {
        _showSuccessDialog(record, synced: true);
      }
    } else {
      // Offline: queue for later
      await ref.read(syncProvider.notifier).queueRecord(record);

      if (mounted) {
        _showSuccessDialog(record, synced: false);
      }
    }
  }

  void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Submitting attendance...'),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(
    AttendanceRecordModel record, {
    required bool synced,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              synced ? Icons.check_circle : Icons.schedule,
              color: synced ? Colors.green : Colors.orange,
            ),
            SizedBox(width: 8),
            Text(synced ? 'Success!' : 'Saved Offline'),
          ],
        ),
        content: Text(
          synced
              ? 'Attendance recorded at ${widget.siteName}.\n\n'
                    'Time: ${record.scanTime.hour}:${record.scanTime.minute.toString().padLeft(2, '0')}\n'
                    'Device: ${record.deviceName}'
              : 'Attendance saved locally. It will sync automatically when you have internet.\n\n'
                    'Site: ${widget.siteName}\n'
                    'Time: ${record.scanTime.hour}:${record.scanTime.minute.toString().padLeft(2, '0')}',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/home');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Shows error as a SnackBar
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

//Reuseable widgets

/// Card widget for grouping related information
class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Header: icon + title
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 20.r),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Content
          ...children,
        ],
      ),
    );
  }
}

/// Row widget for label-value pairs
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
