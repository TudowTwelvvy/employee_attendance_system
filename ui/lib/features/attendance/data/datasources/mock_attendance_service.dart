import '../models/attendance_record_model.dart';


class MockAttendanceService {
  /// In-memory storage of submitted records (for testing)
  static final List<AttendanceRecordModel> _submittedRecords = [];

  /// Submit attendance record
  /// 
  /// Simulates network delay and stores record locally.
  static Future<bool> submitAttendance(AttendanceRecordModel record) async {
    // Simulate API delay (1 second)
    await Future.delayed(const Duration(seconds: 1));
    
    // Store in memory 
    _submittedRecords.add(record);
    
    // Simulate 95% success rate (random failure for testing)
    
    return true; // Always succeed for now
  }

  /// Get all submitted records (for attendance history)
  static List<AttendanceRecordModel> getSubmittedRecords() {
    return List.unmodifiable(_submittedRecords);
  }

  /// Clear all records (for testing)
  static void clearRecords() {
    _submittedRecords.clear();
  }
}