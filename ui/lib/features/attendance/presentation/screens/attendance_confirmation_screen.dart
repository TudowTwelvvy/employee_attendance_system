import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
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
  ConsumerState<AttendanceConfirmationScreen> createState() => _AttendanceConfirmationScreenState();
}

class _AttendanceConfirmationScreenState extends ConsumerState<AttendanceConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    
    // Get GPS location as soon as screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).getLocationAndValidate(
        siteLatitude: widget.siteLatitude,
        siteLongitude: widget.siteLongitude,
        radiusInMeters: widget.radiusInMeters,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch location state for updates
    final locationState = ref.watch(locationProvider);
    final now = DateTime.now();
    final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final dateString = '${now.day}/${now.month}/${now.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Attendance')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.check_circle, size: 80.r, color: Colors.green),
              SizedBox(height: 16.h),
              Text('Attendance Check-In', style: AppTheme.headingMedium, textAlign: TextAlign.center),
              SizedBox(height: 24.h),

              // Site info
              _InfoCard(
                title: 'Work Site',
                icon: Icons.location_on,
                children: [
                  _InfoRow(label: 'Site Name', value: widget.siteName),
                  _InfoRow(label: 'Site ID', value: widget.siteId),
                  _InfoRow(label: 'Allowed Radius', value: '${widget.radiusInMeters}m'),
                ],
              ),
              SizedBox(height: 16.h),

              // Date & Time
              _InfoCard(
                title: 'Date & Time',
                icon: Icons.access_time,
                children: [
                  _InfoRow(label: 'Date', value: dateString),
                  _InfoRow(label: 'Time', value: timeString),
                ],
              ),
              SizedBox(height: 16.h),

              // GPS Location — REAL DATA NOW!
              _InfoCard(
                title: 'GPS Location',
                icon: Icons.gps_fixed,
                children: [
                  if (locationState.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (locationState.errorMessage != null)
                    Text(
                      locationState.errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 14.sp),
                    )
                  else ...[
                    _InfoRow(
                      label: 'Your Latitude',
                      value: locationState.position != null 
                          ? '${locationState.position!.latitude.toStringAsFixed(6)}°'
                          : 'Unknown',
                    ),
                    _InfoRow(
                      label: 'Your Longitude',
                      value: locationState.position != null
                          ? '${locationState.position!.longitude.toStringAsFixed(6)}°'
                          : 'Unknown',
                    ),
                    _InfoRow(
                      label: 'Accuracy',
                      value: locationState.position != null
                          ? '${locationState.position!.accuracy.toStringAsFixed(1)} meters'
                          : 'Unknown',
                    ),
                    _InfoRow(
                      label: 'Distance from Site',
                      value: locationState.distanceFromSite != null
                          ? '${locationState.distanceFromSite!.toStringAsFixed(1)} meters'
                          : 'Unknown',
                    ),
                    SizedBox(height: 8.h),
                    // Geofence status
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: locationState.isWithinGeofence 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: locationState.isWithinGeofence ? Colors.green : Colors.red,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            locationState.isWithinGeofence ? Icons.check_circle : Icons.error,
                            color: locationState.isWithinGeofence ? Colors.green : Colors.red,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              locationState.isWithinGeofence
                                  ? '✅ Within geofence — You are at the site!'
                                  : '❌ Outside geofence — You are too far from the site!',
                              style: TextStyle(
                                color: locationState.isWithinGeofence ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 16.h),

              // Device info (still mock — next lesson)
              _InfoCard(
                title: 'Device Information',
                icon: Icons.phone_android,
                children: const [
                  _InfoRow(label: 'Device', value: 'Samsung Galaxy S21'),
                  _InfoRow(label: 'OS', value: 'Android 14'),
                  _InfoRow(label: 'App Version', value: '1.0.0'),
                ],
              ),
              SizedBox(height: 32.h),

              // Submit button — only enabled if within geofence!
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

  void _submitAttendance(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Success!'),
        content: const Text('Your attendance has been recorded successfully.'),
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
}

/// Reusable card widget for information sections
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
          // Card header: icon + title
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
          // Spread operator (...) inserts all children
          ...children,
        ],
      ),
    );
  }
}


/// Reusable row widget for label-value pairs
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        // Puts space between label and value
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
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