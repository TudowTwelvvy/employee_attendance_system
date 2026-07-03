/// AttendanceRecordModel holds ALL data for one attendance check-in.
/// 
/// This is what gets sent to the API when the user taps "Confirm."
class AttendanceRecordModel {
  final String employeeId;
  final String employeeName;
  final String siteId;
  final String siteName;
  final String qrCodeValue;
  final double latitude;
  final double longitude;
  final String deviceName;
  final String deviceModel;
  final String operatingSystem;
  final String appVersion;
  final DateTime scanTime;

  AttendanceRecordModel({
    required this.employeeId,
    required this.employeeName,
    required this.siteId,
    required this.siteName,
    required this.qrCodeValue,
    required this.latitude,
    required this.longitude,
    required this.deviceName,
    required this.deviceModel,
    required this.operatingSystem,
    required this.appVersion,
    required this.scanTime,
  });

  /// Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'employeeName': employeeName,
      'siteId': siteId,
      'siteName': siteName,
      'qrCodeValue': qrCodeValue,
      'latitude': latitude,
      'longitude': longitude,
      'deviceName': deviceName,
      'deviceModel': deviceModel,
      'operatingSystem': operatingSystem,
      'appVersion': appVersion,
      'scanTime': scanTime.toIso8601String(),
      'scanDate': '${scanTime.year}-${scanTime.month.toString().padLeft(2, '0')}-${scanTime.day.toString().padLeft(2, '0')}',
    };
  }

  @override
  String toString() {
    return 'AttendanceRecord($employeeName at $siteName on ${scanTime.toIso8601String()})';
  }
}