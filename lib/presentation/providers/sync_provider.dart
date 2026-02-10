import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/sync_queue_local_data_source.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/connectivity_listener.dart';
import '../../core/network/network_info.dart';
import 'subject_notifier.dart';
import 'task_notifier.dart';

// ─── Data Source Providers ────────────────────────────────────

final syncQueueDataSourceProvider = Provider<SyncQueueLocalDataSource>((ref) {
  return SyncQueueLocalDataSourceImpl(
    databaseHelper: ref.watch(databaseHelperProvider),
  );
});

// ─── Service Providers ───────────────────────────────────────

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    syncQueue: ref.watch(syncQueueDataSourceProvider),
    subjectRemoteDataSource: ref.watch(subjectRemoteDataSourceProvider),
    taskRemoteDataSource: ref.watch(taskRemoteDataSourceProvider),
    subjectLocalDataSource: ref.watch(subjectLocalDataSourceProvider),
    taskLocalDataSource: ref.watch(taskLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
    databaseHelper: ref.watch(databaseHelperProvider),
  );
});

final connectivityListenerProvider = Provider<ConnectivityListener>((ref) {
  final listener = ConnectivityListener(
    syncService: ref.watch(syncServiceProvider),
  );
  ref.onDispose(() => listener.dispose());
  return listener;
});

// ─── State Providers ─────────────────────────────────────────

/// State for sync status with upload/download counts
class SyncState {
  final bool isSyncing;
  final int pendingCount;
  final int uploadedCount;
  final int downloadedCount;
  final String? lastError;
  final DateTime? lastSyncTime;

  const SyncState({
    this.isSyncing = false,
    this.pendingCount = 0,
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.lastError,
    this.lastSyncTime,
  });

  SyncState copyWith({
    bool? isSyncing,
    int? pendingCount,
    int? uploadedCount,
    int? downloadedCount,
    String? lastError,
    DateTime? lastSyncTime,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      pendingCount: pendingCount ?? this.pendingCount,
      uploadedCount: uploadedCount ?? this.uploadedCount,
      downloadedCount: downloadedCount ?? this.downloadedCount,
      lastError: lastError,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

/// StateNotifier for managing sync state
class SyncNotifier extends StateNotifier<SyncState> {
  final SyncService syncService;

  SyncNotifier(this.syncService) : super(const SyncState());

  /// Trigger a full bidirectional sync
  Future<SyncResult> syncNow() async {
    state = state.copyWith(isSyncing: true, lastError: null);

    try {
      final result = await syncService.fullSync();
      final pendingCount = await syncService.getPendingCount();

      state = state.copyWith(
        isSyncing: false,
        pendingCount: pendingCount,
        uploadedCount: result.uploaded,
        downloadedCount: result.downloaded,
        lastSyncTime: DateTime.now(),
      );
      return result;
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        lastError: e.toString(),
      );
      return const SyncResult();
    }
  }

  /// Refresh the pending count
  Future<void> refreshPendingCount() async {
    try {
      final count = await syncService.getPendingCount();
      state = state.copyWith(pendingCount: count);
    } catch (_) {}
  }
}

final syncNotifierProvider =
    StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier(ref.watch(syncServiceProvider));
});
