/// EmployeeModel represents an employee in the admin system.
///
/// This is different from UserEntity because it includes admin-specific fields like status and join date.
class EmployeeModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String status; // 'Active', 'Inactive', 'Suspended'
  final DateTime joinDate;
  final String? phoneNumber;
  final String? department;

  EmployeeModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.status,
    required this.joinDate,
    this.phoneNumber,
    this.department,
  });

  /// Create from JSON (for future API integration)
  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Employee',
      status: json['status'] ?? 'Active',
      joinDate: DateTime.parse(json['joinDate'] as String),
      phoneNumber: json['phoneNumber'],
      department: json['department'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role,
      'status': status,
      'joinDate': joinDate.toIso8601String(),
      'phoneNumber': phoneNumber,
      'department': department,
    };
  }

  /// Get initials for avatar (e.g., "Twelvvy Tudow" → "TT")
  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  /// Format join date for display
  String get formattedJoinDate {
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
    return '${joinDate.day} ${months[joinDate.month]} ${joinDate.year}';
  }
}
