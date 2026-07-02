import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

/// AttendanceConfirmationScreen shows after scanning a valid QR code.
/// 
/// It displays:
/// - Site information
/// - Current time (from device clock)
/// - Mock GPS location (real GPS in next lesson)
/// - Mock device info (real device info in a future lesson)
/// - Submit button
class AttendanceConfirmationScreen extends StatelessWidget {
  /// These values come from the QR scanner via GoRouter's 'extra'
  final String siteId;
  final String siteName;

  const AttendanceConfirmationScreen({
    super.key,
    required this.siteId,
    required this.siteName,
  });

  @override
  Widget build(BuildContext context) {
    // Get current date and time from the device's clock
    final now = DateTime.now();
    
    // Format time as HH:MM (pad with zero if needed)
    final timeString = 
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    // Format date as DD/MM/YYYY
    final dateString = '${now.day}/${now.month}/${now.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Attendance')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success icon (large green checkmark)
              Icon(
                Icons.check_circle,
                size: 80.r,
                color: Colors.green,
              ),
              SizedBox(height: 16.h),
              
              // Title
              Text(
                'Attendance Check-In',
                style: AppTheme.headingMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              // Site info card
              _InfoCard(
                title: 'Work Site',
                icon: Icons.location_on,
                children: [
                  _InfoRow(label: 'Site Name', value: siteName),
                  _InfoRow(label: 'Site ID', value: siteId),
                ],
              ),
              SizedBox(height: 16.h),

              // Time info card
              _InfoCard(
                title: 'Date & Time',
                icon: Icons.access_time,
                children: [
                  _InfoRow(label: 'Date', value: dateString),
                  _InfoRow(label: 'Time', value: timeString),
                ],
              ),
              SizedBox(height: 16.h),

              // Mock GPS card 
              _InfoCard(
                title: 'GPS Location',
                icon: Icons.gps_fixed,
                children: [
                  _InfoRow(label: 'Latitude', value: '-25.7479°'),
                  _InfoRow(label: 'Longitude', value: '28.2293°'),
                  _InfoRow(label: 'Accuracy', value: '4.5 meters'),
                  _InfoRow(
                    label: 'Status', 
                    value: '✅ Within geofence', 
                    valueColor: Colors.green,
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Mock device info card
              _InfoCard(
                title: 'Device Information',
                icon: Icons.phone_android,
                children: [
                  _InfoRow(label: 'Device', value: 'Samsung Galaxy S21'),
                  _InfoRow(label: 'OS', value: 'Android 14'),
                  _InfoRow(label: 'App Version', value: '1.0.0'),
                ],
              ),
              SizedBox(height: 32.h),

              // Confirm button
              SizedBox(
                height: 50.h,
                child: ElevatedButton.icon(
                  onPressed: () => _submitAttendance(context),
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

  /// Shows success dialog and navigates home
  void _submitAttendance(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: const Text('Success!'),
        content: const Text('Your attendance has been recorded successfully.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.go('/home'); // Navigate to home (replaces stack)
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