import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmployeeListItem extends StatelessWidget {
  final String name;
  final String department;
  final bool isCheckedIn;

  const EmployeeListItem({
    super.key,
    required this.name,
    required this.department,
    required this.isCheckedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24.r,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, size: 24.r),
          ),
          
          SizedBox(width: 12.w),
          
          // Name and Department (takes remaining space)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  department,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          // Status icon
          Icon(
            isCheckedIn ? Icons.check_circle : Icons.cancel,
            color: isCheckedIn ? Colors.green : Colors.red,
            size: 24.r,
          ),
        ],
      ),
    );
  }
}