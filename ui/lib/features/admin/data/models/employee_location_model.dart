class EmployeeLocationModel {
  final String employeeId;
  final String employeeName;
  final String siteId;
  final String siteName;
  final double latitude;
  final double longitude;
  final DateTime lastUpdated;
  final String status; // 'online', 'offline', 'checked_in', 'checked_out'
  final String? deviceName;

  EmployeeLocationModel({
    required this.employeeId,
    required this.employeeName,
    required this.siteId,
    required this.siteName,
    required this.latitude,
    required this.longitude,
    required this.lastUpdated,
    required this.status,
    this.deviceName,
  });

  /// Format lastUpdated as "2 min ago" or "Just now"
  String get timeAgo {
    final diff = DateTime.now().difference(lastUpdated);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} days ago';
  }

  /// Is this employee currently checked in?
  bool get isCheckedIn => status == 'checked_in';

  /// Is this employee's location recent (within 5 minutes)?
  bool get isRecent => DateTime.now().difference(lastUpdated).inMinutes < 5;
}
