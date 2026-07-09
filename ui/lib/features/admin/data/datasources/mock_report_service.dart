import '../models/attendance_report_model.dart';

/// MockReportService generates fake attendance data for testing.
class MockReportService {
  /// Generate mock attendance records for a date range.
  static List<AttendanceReportModel> generateReport(
    DateTime startDate,
    DateTime endDate,
  ) {
    final records = <AttendanceReportModel>[];
    final employees = [
      _Employee('emp_001', 'John Smith', 'Head Office'),
      _Employee('emp_002', 'Sarah Johnson', 'Construction Site A'),
      _Employee('emp_003', 'Michael Brown', 'Warehouse B'),
      _Employee('emp_004', 'Emily Davis', 'Head Office'),
      _Employee('emp_005', 'David Wilson', 'Construction Site A'),
    ];

    // Generate records for each day in range
    var currentDate = startDate;
    while (!currentDate.isAfter(endDate)) {
      // Skip weekends
      if (currentDate.weekday != DateTime.saturday &&
          currentDate.weekday != DateTime.sunday) {
        for (final emp in employees) {
          // Random attendance pattern
          final status = _generateStatus(emp.id, currentDate);
          records.add(
            AttendanceReportModel(
              employeeId: emp.id,
              employeeName: emp.name,
              siteName: emp.site,
              date: currentDate,
              checkInTime: status == 'Absent'
                  ? null
                  : _generateCheckInTime(status),
              status: status,
              latitude: status == 'Absent' ? null : -25.7479 + _randomOffset(),
              longitude: status == 'Absent' ? null : 28.2293 + _randomOffset(),
              deviceName: status == 'Absent' ? null : 'Samsung Galaxy S21',
            ),
          );
        }
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return records;
  }

  /// Generate status based on employee and day (deterministic "random")
  static String _generateStatus(String empId, DateTime date) {
    // Use a simple hash to make it consistent
    final hash = empId.hashCode + date.day + date.month;
    final mod = hash % 100;
    if (mod < 75) return 'On Time'; // 75% on time
    if (mod < 90) return 'Late'; // 15% late
    return 'Absent'; // 10% absent
  }

  /// Generate check-in time based on status
  static DateTime? _generateCheckInTime(String status) {
    final base = DateTime(2026, 1, 1, 8, 0); // 8:00 AM
    if (status == 'On Time') {
      // Between 7:30 and 8:30
      final offset = (base.minute + 30) % 60;
      return base.add(Duration(minutes: offset));
    } else {
      // Late: between 8:31 and 10:00
      final lateMinutes = 31 + (status.hashCode % 90);
      return base.add(Duration(minutes: lateMinutes));
    }
  }

  static double _randomOffset() {
    return (DateTime.now().millisecond % 100) / 10000;
  }
}

/// Simple helper class for mock employee data
class _Employee {
  final String id;
  final String name;
  final String site;

  _Employee(this.id, this.name, this.site);
}
