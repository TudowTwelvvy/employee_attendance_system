import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/attendance/data/models/attendance_record_model.dart';

/// OfflineQueueService saves attendance records when there's no internet.
class OfflineQueueService {
  OfflineQueueService._();
  static final OfflineQueueService _instance = OfflineQueueService._();
  factory OfflineQueueService() => _instance;

  static const _storage = FlutterSecureStorage();
  static const String _queueKey = 'attendance_queue';

  /// Add a record to the offline queue
  /// When internet is back, these records will be synced.
  Future<void> addToQueue(AttendanceRecordModel record) async {
    // Get existing queue
    final existing = await getQueue();
    
    // Add new record
    existing.add(record);
    
    // Save back to storage
    final jsonList = existing.map((r) => r.toJson()).toList();
    await _storage.write(key: _queueKey, value: jsonEncode(jsonList));
  }

  /// Get all queued records
  Future<List<AttendanceRecordModel>> getQueue() async {
    final jsonString = await _storage.read(key: _queueKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    // Parse JSON string back to list of objects
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => AttendanceRecordModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Remove a record from the queue (after successful sync)
  Future<void> removeFromQueue(AttendanceRecordModel record) async {
    final existing = await getQueue();
    
    // Remove the record by matching scan time (unique identifier)
    existing.removeWhere((r) => r.scanTime == record.scanTime);
    
    // Save updated queue
    if (existing.isEmpty) {
      await _storage.delete(key: _queueKey);
    } else {
      final jsonList = existing.map((r) => r.toJson()).toList();
      await _storage.write(key: _queueKey, value: jsonEncode(jsonList));
    }
  }

  /// Clear entire queue
  Future<void> clearQueue() async {
    await _storage.delete(key: _queueKey);
  }

  /// Get count of pending records
  Future<int> getPendingCount() async {
    final queue = await getQueue();
    return queue.length;
  }
}