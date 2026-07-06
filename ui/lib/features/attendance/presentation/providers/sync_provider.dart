import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/offline_queue_service.dart';
import '../../data/datasources/mock_attendance_service.dart';
import '../../data/models/attendance_record_model.dart';

/// SyncState tracks sync status
class SyncState {
  final bool isSyncing;
  final int pendingCount;
  final String? lastSyncMessage;

  const SyncState({
    this.isSyncing = false,
    this.pendingCount = 0,
    this.lastSyncMessage,
  });

  SyncState copyWith({
    bool? isSyncing,
    int? pendingCount,
    String? lastSyncMessage,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncMessage: lastSyncMessage ?? this.lastSyncMessage,
    );
  }
}

/// SyncNotifier manages offline queue and sync
class SyncNotifier extends StateNotifier<SyncState> {
  final ConnectivityService _connectivity = ConnectivityService();
  final OfflineQueueService _queue = OfflineQueueService();

  SyncNotifier() : super(const SyncState()) {
    // Check pending count when created
    _updatePendingCount();
    
    // Listen for internet changes
    _connectivity.onConnectivityChanged.listen((_) {
      _autoSync();
    });
  }

  /// Update pending count from storage
  Future<void> _updatePendingCount() async {
    final count = await _queue.getPendingCount();
    state = state.copyWith(pendingCount: count);
  }

  /// Queue a record for later sync
  Future<void> queueRecord(AttendanceRecordModel record) async {
    await _queue.addToQueue(record);
    await _updatePendingCount();
  }

  /// Try to sync all pending records
  Future<void> syncNow() async {
    // Check if online
    final isOnline = await _connectivity.isConnected();
    if (!isOnline) {
      state = state.copyWith(
        lastSyncMessage: 'No internet connection. Records queued.',
      );
      return;
    }

    // Get pending records
    final pending = await _queue.getQueue();
    if (pending.isEmpty) {
      state = state.copyWith(
        lastSyncMessage: 'All records are synced!',
      );
      return;
    }

    // Start syncing
    state = state.copyWith(isSyncing: true);

    int successCount = 0;
    int failCount = 0;

    for (final record in pending) {
      try {
        // Try to submit
        final success = await MockAttendanceService.submitAttendance(record);
        
        if (success) {
          // Remove from queue on success
          await _queue.removeFromQueue(record);
          successCount++;
        } else {
          failCount++;
        }
      } catch (e) {
        failCount++;
      }
    }

    // Update state
    await _updatePendingCount();
    state = state.copyWith(
      isSyncing: false,
      lastSyncMessage: 'Synced: $successCount success, $failCount failed',
    );
  }

  /// Auto-sync when internet comes back
  Future<void> _autoSync() async {
    final isOnline = await _connectivity.isConnected();
    if (isOnline) {
      final pending = await _queue.getPendingCount();
      if (pending > 0) {
        await syncNow();
      }
    }
  }
}

/// Provider for sync state
final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier();
});