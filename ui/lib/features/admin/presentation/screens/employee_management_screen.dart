import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/responsive_sizes.dart';
import '../../data/datasources/mock_employee_service.dart';
import '../../data/models/employee_model.dart';

class EmployeeManagementScreen extends ConsumerStatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  ConsumerState<EmployeeManagementScreen> createState() =>
      _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState
    extends ConsumerState<EmployeeManagementScreen> {
  // State for search and filters
  String _searchQuery = '';
  String? _roleFilter;
  String? _statusFilter;

  // Sorting
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final sizes = ResponsiveSizes(context);
    final isDesktop = sizes.isDesktop;

    // Get filtered and sorted employees
    var employees = _getFilteredEmployees();
    employees = _sortEmployees(employees);

    return Scaffold(
      body: SafeArea(
        child: isDesktop
            ? _buildDesktopLayout(employees, sizes)
            : _buildMobileLayout(employees, sizes),
      ),
    );
  }

  // DESKTOP: Column with Expanded (works because screen is tall)
  Widget _buildDesktopLayout(
    List<EmployeeModel> employees,
    ResponsiveSizes sizes,
  ) {
    return sizes.centeredContent(
      child: Padding(
        padding: EdgeInsets.all(sizes.paddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Employee Management', style: AppTheme.headingMedium(context)),
            SizedBox(height: sizes.spaceSmall),
            Text(
              'Manage your organization\'s employees',
              style: AppTheme.bodyLarge(context),
            ),
            SizedBox(height: sizes.spaceLarge),

            _buildFiltersRow(true),
            SizedBox(height: sizes.spaceMedium),

            _buildStatsRow(employees, true),
            SizedBox(height: sizes.spaceLarge),

            // Expanded works here because Column has bounded height (Scaffold body)
            Expanded(child: _buildEmployeeTable(employees, true)),
          ],
        ),
      ),
    );
  }

  // MOBILE: SingleChildScrollView (everything scrolls, NO Expanded)
  Widget _buildMobileLayout(
    List<EmployeeModel> employees,
    ResponsiveSizes sizes,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(sizes.paddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Employee Management', style: AppTheme.headingMedium(context)),
            SizedBox(height: sizes.spaceSmall),
            Text(
              'Manage your organization\'s employees',
              style: AppTheme.bodyLarge(context),
            ),
            SizedBox(height: sizes.spaceLarge),

            _buildFiltersRow(false),
            SizedBox(height: sizes.spaceMedium),

            _buildStatsRow(employees, false),
            SizedBox(height: sizes.spaceLarge),

            // NO Expanded! Just the list directly
            _buildEmployeeTable(employees, false),
          ],
        ),
      ),
    );
  }

  /// Builds search bar and filter dropdowns
  Widget _buildFiltersRow(bool isDesktop) {
    final sizes = ResponsiveSizes(context);

    if (isDesktop) {
      // Desktop: horizontal row
      return Row(
        children: [
          // Search field
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          const SizedBox(width: 16),
          // Role filter
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: _roleFilter,
              hint: const Text('All Roles'),
              items: ['All', 'Admin', 'Manager', 'Employee']
                  .map(
                    (role) => DropdownMenuItem(
                      value: role == 'All' ? null : role,
                      child: Text(role),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _roleFilter = value);
              },
            ),
          ),
          const SizedBox(width: 16),
          // Status filter
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: _statusFilter,
              hint: const Text('All Status'),
              items: ['All', 'Active', 'Inactive', 'Suspended']
                  .map(
                    (status) => DropdownMenuItem(
                      value: status == 'All' ? null : status,
                      child: Text(status),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _statusFilter = value);
              },
            ),
          ),
        ],
      );
    } else {
      // Mobile: vertical stack
      return Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: _roleFilter,
                  hint: const Text('All'),
                  items: ['All', 'Admin', 'Manager', 'Employee']
                      .map(
                        (role) => DropdownMenuItem(
                          value: role == 'All' ? null : role,
                          child: Text(role),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _roleFilter = value);
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: _statusFilter,
                  hint: const Text('All'),
                  items: ['All', 'Active', 'Inactive', 'Suspended']
                      .map(
                        (status) => DropdownMenuItem(
                          value: status == 'All' ? null : status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _statusFilter = value);
                  },
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  /// Builds stats cards row
  Widget _buildStatsRow(List<EmployeeModel> employees, bool isDesktop) {
    final total = employees.length;
    final active = employees.where((e) => e.status == 'Active').length;
    final inactive = employees.where((e) => e.status == 'Inactive').length;
    final suspended = employees.where((e) => e.status == 'Suspended').length;

    final stats = [
      _StatItem('Total', total.toString(), Colors.blue),
      _StatItem('Active', active.toString(), Colors.green),
      _StatItem('Inactive', inactive.toString(), Colors.grey),
      _StatItem('Suspended', suspended.toString(), Colors.orange),
    ];

    if (isDesktop) {
      return Row(
        children: stats.map((stat) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _StatCard(stat: stat),
            ),
          );
        }).toList(),
      );
    } else {
      return Wrap(
        spacing: 12.w,
        runSpacing: 12.h,
        children: stats.map((stat) {
          return SizedBox(
            width: (MediaQuery.of(context).size.width - 64) / 2,
            child: _StatCard(stat: stat),
          );
        }).toList(),
      );
    }
  }

  /// Builds the employee data table
  Widget _buildEmployeeTable(List<EmployeeModel> employees, bool isDesktop) {
    if (employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No employees found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // MOBILE: Use Column with map instead of ListView (avoids nested scrolling)
    if (!isDesktop) {
      return Column(
        children: employees.map((e) => _EmployeeListTile(employee: e)).toList(),
      );
    }

    // DESKTOP: DataTable (unchanged)
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns: [
            DataColumn(
              label: const Text('Employee'),
              onSort: (i, a) => _setSort(i, a),
            ),
            DataColumn(
              label: const Text('Role'),
              onSort: (i, a) => _setSort(i, a),
            ),
            DataColumn(
              label: const Text('Status'),
              onSort: (i, a) => _setSort(i, a),
            ),
            DataColumn(
              label: const Text('Department'),
              onSort: (i, a) => _setSort(i, a),
            ),
            DataColumn(
              label: const Text('Joined'),
              onSort: (i, a) => _setSort(i, a),
            ),
            const DataColumn(label: Text('Actions')),
          ],
          rows: employees.map((employee) {
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          employee.initials,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              employee.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              employee.email,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(_RoleBadge(role: employee.role)),
                DataCell(_StatusBadge(status: employee.status)),
                DataCell(Text(employee.department ?? '-')),
                DataCell(Text(employee.formattedJoinDate)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          size: 20,
                          color: Colors.red,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // Helper to reduce repetition
  void _setSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  /// Gets filtered employees based on search and filters
  List<EmployeeModel> _getFilteredEmployees() {
    // Start with a modifiable copy
    var result = MockEmployeeService.getAllEmployees();

    // Apply search
    if (_searchQuery.isNotEmpty) {
      result = MockEmployeeService.searchEmployees(_searchQuery);
    }

    // Apply role filter
    if (_roleFilter != null) {
      result = result.where((e) => e.role == _roleFilter).toList();
    }

    // Apply status filter
    if (_statusFilter != null) {
      result = result.where((e) => e.status == _statusFilter).toList();
    }

    return result;
  }

  /// Sorts employees based on current sort settings
  List<EmployeeModel> _sortEmployees(List<EmployeeModel> employees) {
    // Create a NEW modifiable list (copy of the original)
    var sortedList = List<EmployeeModel>.from(employees);

    switch (_sortColumnIndex) {
      case 0: // Name
        sortedList.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
      case 1: // Role
        sortedList.sort((a, b) => a.role.compareTo(b.role));
        break;
      case 2: // Status
        sortedList.sort((a, b) => a.status.compareTo(b.status));
        break;
      case 3: // Department
        sortedList.sort(
          (a, b) => (a.department ?? '').compareTo(b.department ?? ''),
        );
        break;
      case 4: // Join date
        sortedList.sort((a, b) => a.joinDate.compareTo(b.joinDate));
        break;
    }

    if (!_sortAscending) {
      sortedList = sortedList.reversed.toList();
    }

    return sortedList;
  }
}

/// Stat item data class
class _StatItem {
  final String label;
  final String value;
  final Color color;

  _StatItem(this.label, this.value, this.color);
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  final _StatItem stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(stat.label, style: TextStyle(fontSize: 14, color: Colors.grey)),
          SizedBox(height: 8),
          Text(
            stat.value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: stat.color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Role badge widget
class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (role) {
      case 'Admin':
        color = Colors.red;
        break;
      case 'Manager':
        color = Colors.orange;
        break;
      default:
        color = AppTheme.primaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Status badge widget
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Active':
        color = Colors.green;
        break;
      case 'Inactive':
        color = Colors.grey;
        break;
      case 'Suspended':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8),
        Text(
          status,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Mobile employee list tile
class _EmployeeListTile extends StatelessWidget {
  final EmployeeModel employee;

  const _EmployeeListTile({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    employee.initials,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.fullName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        employee.email,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                _RoleBadge(role: employee.role),
                SizedBox(width: 8.w),
                _StatusBadge(status: employee.status),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Department: ${employee.department ?? '-'}',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            Text(
              'Joined: ${employee.formattedJoinDate}',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
