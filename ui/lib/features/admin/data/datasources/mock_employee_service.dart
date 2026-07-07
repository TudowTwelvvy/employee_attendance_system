import '../models/employee_model.dart';

/// MockEmployeeService provides fake employee data for testing.
class MockEmployeeService {
  static final List<EmployeeModel> _employees = [
    EmployeeModel(
      id: 'emp_001',
      fullName: 'John Smith',
      email: 'john.smith@company.com',
      role: 'Admin',
      status: 'Active',
      joinDate: DateTime(2023, 1, 15),
      phoneNumber: '+27 82 123 4567',
      department: 'IT',
    ),
    EmployeeModel(
      id: 'emp_002',
      fullName: 'Sarah Johnson',
      email: 'sarah.j@company.com',
      role: 'Manager',
      status: 'Active',
      joinDate: DateTime(2023, 3, 22),
      phoneNumber: '+27 83 234 5678',
      department: 'Operations',
    ),
    EmployeeModel(
      id: 'emp_003',
      fullName: 'Michael Brown',
      email: 'm.brown@company.com',
      role: 'Employee',
      status: 'Active',
      joinDate: DateTime(2023, 6, 10),
      phoneNumber: '+27 84 345 6789',
      department: 'Construction',
    ),
    EmployeeModel(
      id: 'emp_004',
      fullName: 'Emily Davis',
      email: 'emily.d@company.com',
      role: 'Employee',
      status: 'Inactive',
      joinDate: DateTime(2023, 8, 5),
      phoneNumber: '+27 85 456 7890',
      department: 'Warehouse',
    ),
    EmployeeModel(
      id: 'emp_005',
      fullName: 'David Wilson',
      email: 'd.wilson@company.com',
      role: 'Manager',
      status: 'Active',
      joinDate: DateTime(2023, 11, 18),
      phoneNumber: '+27 86 567 8901',
      department: 'Security',
    ),
    EmployeeModel(
      id: 'emp_006',
      fullName: 'Lisa Anderson',
      email: 'lisa.a@company.com',
      role: 'Employee',
      status: 'Suspended',
      joinDate: DateTime(2024, 1, 30),
      phoneNumber: '+27 87 678 9012',
      department: 'HR',
    ),
    EmployeeModel(
      id: 'emp_007',
      fullName: 'James Taylor',
      email: 'j.taylor@company.com',
      role: 'Employee',
      status: 'Active',
      joinDate: DateTime(2024, 4, 12),
      phoneNumber: '+27 88 789 0123',
      department: 'Construction',
    ),
    EmployeeModel(
      id: 'emp_008',
      fullName: 'Patricia Martinez',
      email: 'patricia.m@company.com',
      role: 'Admin',
      status: 'Active',
      joinDate: DateTime(2024, 6, 20),
      phoneNumber: '+27 89 890 1234',
      department: 'Finance',
    ),
  ];

  /// Get all employees
  ///
  /// Returns a modifiable copy so callers can sort/filter freely
  static List<EmployeeModel> getAllEmployees() {
    return List<EmployeeModel>.from(_employees);
  }

  /// Search employees by name or email
  ///
  /// Returns a modifiable list
  static List<EmployeeModel> searchEmployees(String query) {
    final lowerQuery = query.toLowerCase();
    return _employees.where((e) {
      return e.fullName.toLowerCase().contains(lowerQuery) ||
          e.email.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Filter by role
  static List<EmployeeModel> filterByRole(String role) {
    return _employees.where((e) => e.role == role).toList();
  }

  /// Filter by status
  static List<EmployeeModel> filterByStatus(String status) {
    return _employees.where((e) => e.status == status).toList();
  }
}
