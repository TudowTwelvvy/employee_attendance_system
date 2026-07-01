
class UserEntity {
  final String id;
  final String email;
  final String fullName;
  final String role;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  /// Check if user is an admin
  bool get isAdmin => role == 'Admin';

  /// Check if user is a manager
  bool get isManager => role == 'Manager';

  /// Check if user is a regular employee
  bool get isEmployee => role == 'Employee';

  /// Get display name (first name only)
  String get firstName => fullName.split(' ').first;

  @override
  String toString() => 'UserEntity(id: $id, name: $fullName, role: $role)';
}