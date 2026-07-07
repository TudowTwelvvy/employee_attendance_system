import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/attendance/data/models/attendance_record_model.dart';

class OfflineQueueService {
  OfflineQueueService._();
  static final OfflineQueueService _instance = OfflineQueueService._();
  factory OfflineQueueService() => _instance;

  static const _queueKey = 'attendance_queue';

  Future<void> addToQueue(AttendanceRecordModel record) async {
    final existing = await getQueue();
    existing.add(record);
    await _saveQueue(existing);
  }

  Future<List<AttendanceRecordModel>> getQueue() async {
    String? jsonString;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      jsonString = prefs.getString(_queueKey);
    } else {
      const storage = FlutterSecureStorage();
      jsonString = await storage.read(key: _queueKey);
    }

    if (jsonString == null || jsonString.isEmpty) return [];
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map(
          (json) =>
              AttendanceRecordModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> removeFromQueue(AttendanceRecordModel record) async {
    final existing = await getQueue();
    existing.removeWhere((r) => r.scanTime == record.scanTime);
    await _saveQueue(existing);
  }

  Future<void> clearQueue() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_queueKey);
    } else {
      const storage = FlutterSecureStorage();
      await storage.delete(key: _queueKey);
    }
  }

  Future<int> getPendingCount() async {
    final queue = await getQueue();
    return queue.length;
  }

  Future<void> _saveQueue(List<AttendanceRecordModel> records) async {
    final jsonList = records.map((r) => r.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_queueKey, jsonString);
    } else {
      const storage = FlutterSecureStorage();
      await storage.write(key: _queueKey, value: jsonString);
    }
  }
}
