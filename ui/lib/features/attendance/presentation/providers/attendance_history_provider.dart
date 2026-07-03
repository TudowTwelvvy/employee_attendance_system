import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/mock_attendance_service.dart';
import '../../data/models/attendance_record_model.dart';

class AttendanceHistoryState {
  final bool isLoading;
  final List<AttendanceRecordModel> records;
  final String? errorMessage;

  const AttendanceHistoryState({
    this.isLoading = false,
    this.records = const [],
    this.errorMessage,
  });

  AttendanceHistoryState copyWith({
    bool? isLoading,
    List<AttendanceRecordModel>? records,
    String? errorMessage,
  }) {
    return AttendanceHistoryState(
      isLoading: isLoading ?? this.isLoading,
      records: records ?? this.records,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// AttendanceHistoryNotifier manages fetching history
class AttendanceHistoryNotifier extends StateNotifier<AttendanceHistoryState> {
  AttendanceHistoryNotifier() : super(const AttendanceHistoryState());

  /// Load attendance records from the service
  Future<void> loadRecords() async {
    // Set loading state
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Get records from mock service
      final records = MockAttendanceService.getSubmittedRecords();

      // Update state
      state = state.copyWith(
        isLoading: false,
        records: records,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load history: ${e.toString()}',
      );
    }
  }
}

/// Provider that widgets use to access attendance history
final attendanceHistoryProvider =
    StateNotifierProvider<AttendanceHistoryNotifier, AttendanceHistoryState>((ref) {
  return AttendanceHistoryNotifier();
});