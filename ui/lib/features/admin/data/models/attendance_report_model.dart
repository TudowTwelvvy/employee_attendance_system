class AttendanceReportModel {
  final String employeeId;
  final String employeeName;
  final String siteName;
  final DateTime date;
  final DateTime? checkInTime;
  final String status; // 'On Time', 'Late', 'Absent'
  final double? latitude;
  final double? longitude;
  final String? deviceName;

  AttendanceReportModel({
    required this.employeeId,
    required this.employeeName,
    required this.siteName,
    required this.date,
    this.checkInTime,
    required this.status,
    this.latitude,
    this.longitude,
    this.deviceName,
  });

  /// Format date as "8 Jul 2026"
  String get formattedDate {
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  /// Format time as "08:30" or "-"
  String get formattedTime {
    if (checkInTime == null) return '-';
    final h = checkInTime!.hour.toString().padLeft(2, '0');
    final m = checkInTime!.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Convert to a list for CSV/Excel export
  List<dynamic> toRow() {
    return [
      employeeName,
      siteName,
      formattedDate,
      formattedTime,
      status,
      latitude?.toStringAsFixed(4) ?? '-',
      longitude?.toStringAsFixed(4) ?? '-',
      deviceName ?? '-',
    ];
  }
}
