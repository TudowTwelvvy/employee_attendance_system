import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/attendance_record_model.dart';
import '../providers/attendance_history_provider.dart';

class AttendanceHistoryScreen extends ConsumerStatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  ConsumerState<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState
    extends ConsumerState<AttendanceHistoryScreen> {
  @override
  void initState() {
    super.initState();

    // Load records when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(attendanceHistoryProvider.notifier).loadRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the history state
    final historyState = ref.watch(attendanceHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        actions: [
          // Manual refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(attendanceHistoryProvider.notifier).loadRecords();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        // Pull down to refresh
        onRefresh: () async {
          await ref.read(attendanceHistoryProvider.notifier).loadRecords();
        },
        child: _buildBody(historyState),
      ),
    );
  }

  /// Builds the main body based on state
  Widget _buildBody(AttendanceHistoryState state) {
    // Loading state
    if (state.isLoading && state.records.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error state
    if (state.errorMessage != null && state.records.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64.r, color: Colors.red),
              SizedBox(height: 16.h),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 16.sp),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  ref.read(attendanceHistoryProvider.notifier).loadRecords();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state — no records yet
    if (state.records.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 80.r, color: Colors.grey),
              SizedBox(height: 16.h),
              Text(
                'No Attendance Records',
                style: AppTheme.headingMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'Your attendance history will appear here after you check in.',
                style: AppTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: () => context.push('/attendance/scan'),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('SCAN QR CODE'),
              ),
            ],
          ),
        ),
      );
    }

    // Has records — show the list!
    return ListView.builder(
      // Padding around the entire list
      padding: EdgeInsets.all(16.w),
      // Number of items in the list
      itemCount: state.records.length,
      // Builds one item at a time
      itemBuilder: (context, index) {
        final record = state.records[index];
        return _AttendanceRecordCard(record: record);
      },
    );
  }
}

/// Card widget that displays one attendance record
class _AttendanceRecordCard extends StatelessWidget {
  final AttendanceRecordModel record;

  const _AttendanceRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    // Format the date nicely
    final dateText = _formatDate(record.scanTime);
    final timeText =
        '${record.scanTime.hour.toString().padLeft(2, '0')}:${record.scanTime.minute.toString().padLeft(2, '0')}';

    return Card(
      // Card styling
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Site name and time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Site name (bold)
                Expanded(
                  child: Text(
                    record.siteName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Time badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    timeText,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Date text
            Text(
              dateText,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 12.h),

            // Divider line
            Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
            SizedBox(height: 12.h),

            // Bottom row: Device and location
            Row(
              children: [
                Icon(Icons.phone_android, size: 16.r, color: Colors.grey),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    record.deviceName,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 12.w),
                Icon(Icons.location_on, size: 16.r, color: Colors.grey),
                SizedBox(width: 4.w),
                Text(
                  '${record.latitude.toStringAsFixed(2)}, ${record.longitude.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Formats a DateTime into a human-readable string
  /// 
  /// - Today → "Today"
  /// - Yesterday → "Yesterday"
  /// - Otherwise → "3 July 2026"
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(date.year, date.month, date.day);

    if (recordDate == today) {
      return 'Today';
    } else if (recordDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      // Format: "3 July 2026"
      final months = [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${date.day} ${months[date.month]} ${date.year}';
    }
  }
}