import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/datasources/local/sync_queue_local_data_source.dart';
import '../../data/datasources/local/subject_local_data_source.dart';
import '../../data/datasources/local/task_local_data_source.dart';
import '../../data/datasources/remote/subject_remote_data_source.dart';
import '../../data/datasources/remote/task_remote_data_source.dart';
import '../../data/models/subject_model.dart';
import '../../data/models/task_model.dart';
import '../../data/datasources/local/database_helper.dart';
import '../network/network_info.dart';

/// Result of a full bidirectional sync
class SyncResult {
  final int uploaded;
  final int downloaded;
  final int errors;

  const SyncResult({
    this.uploaded = 0,
    this.downloaded = 0,
    this.errors = 0,
  });

  @override
  String toString() => '↑$uploaded subidos, ↓$downloaded descargados'
      '${errors > 0 ? ', $errors errores' : ''}';
}

/// Possible states of the sync service
enum SyncStatus { idle, syncing, completed, error }

/// Central synchronization service that processes the sync queue
/// and downloads remote data (bidirectional sync)
class SyncService {
  final SyncQueueLocalDataSource syncQueue;
  final SubjectRemoteDataSource subjectRemoteDataSource;
  final TaskRemoteDataSource taskRemoteDataSource;
  final SubjectLocalDataSource subjectLocalDataSource;
  final TaskLocalDataSource taskLocalDataSource;
  final NetworkInfo networkInfo;
  final DatabaseHelper databaseHelper;

  bool _isSyncing = false;

  SyncService({
    required this.syncQueue,
    required this.subjectRemoteDataSource,
    required this.taskRemoteDataSource,
    required this.subjectLocalDataSource,
    required this.taskLocalDataSource,
    required this.networkInfo,
    required this.databaseHelper,
  });

  /// Whether a sync is currently in progress
  bool get isSyncing => _isSyncing;

  /// Perform a full bidirectional sync:
  /// 1. Upload pending local changes → Firestore
  /// 2. Download remote data ← Firestore (last-write-wins)
  Future<SyncResult> fullSync() async {
    if (_isSyncing) {
      log('SyncService: Already syncing, skipping...');
      return const SyncResult();
    }

    if (!await networkInfo.isConnected) {
      log('SyncService: No network connection, skipping...');
      return const SyncResult();
    }

    _isSyncing = true;
    int uploadCount = 0;
    int downloadCount = 0;
    int errorCount = 0;

    try {
      // ─── PHASE 1: UPLOAD (Local → Firestore) ─────────────
      uploadCount += await processQueue();
      await syncPendingRecords();

      // ─── PHASE 2: DOWNLOAD (Firestore → Local) ───────────
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final downloadResult = await downloadFromFirestore(userId);
        downloadCount = downloadResult;
      }
    } catch (e) {
      log('SyncService: Error during full sync: $e');
      errorCount++;
    } finally {
      _isSyncing = false;
    }

    final result = SyncResult(
      uploaded: uploadCount,
      downloaded: downloadCount,
      errors: errorCount,
    );
    log('SyncService: Full sync completed — $result');
    return result;
  }

  /// Download data from Firestore and merge into local DB
  /// Uses last-write-wins strategy based on updated_at timestamp
  /// Returns the number of records downloaded/updated
  Future<int> downloadFromFirestore(String userId) async {
    int downloadCount = 0;

    try {
      // ─── Download Subjects ─────────────────────────────────
      final remoteSubjects = await subjectRemoteDataSource.getSubjects(userId);
      log('SyncService: Downloaded ${remoteSubjects.length} subjects from Firestore');

      for (final remote in remoteSubjects) {
        try {
          final local = await subjectLocalDataSource.getSubject(remote.id);

          if (local == null) {
            // New record — insert locally
            final dataWithSync = _withSyncStatus(remote.toJson(), 'synced');
            final syncedModel = SubjectModel.fromJson(dataWithSync);
            await subjectLocalDataSource.insertSubject(syncedModel);
            downloadCount++;
            await _logSyncHistory(
              tableName: 'subjects',
              recordId: remote.id,
              operation: 'download',
              status: 'completed',
              syncType: 'download',
            );
            log('SyncService: Downloaded new subject ${remote.id}');
          } else {
            // Exists locally — compare timestamps
            final remoteUpdated = _getUpdatedAt(remote.toJson());
            final localUpdated = _getUpdatedAt(local.toJson());

            if (remoteUpdated > localUpdated) {
              // Remote is newer — update local
              final dataWithSync = _withSyncStatus(remote.toJson(), 'synced');
              final syncedModel = SubjectModel.fromJson(dataWithSync);
              await subjectLocalDataSource.updateSubject(syncedModel);
              // Mark as synced directly
              await _updateRecordSyncStatus('subjects', remote.id, 'synced');
              downloadCount++;
              await _logSyncHistory(
                tableName: 'subjects',
                recordId: remote.id,
                operation: 'download',
                status: 'completed',
                syncType: 'download',
              );
              log('SyncService: Updated subject ${remote.id} (remote is newer)');
            }
            // If local is newer or equal, skip (local wins)
          }
        } catch (e) {
          log('SyncService: Failed to merge subject ${remote.id}: $e');
        }
      }

      // ─── Download Tasks ────────────────────────────────────
      final remoteTasks = await taskRemoteDataSource.getAllTasks(userId);
      log('SyncService: Downloaded ${remoteTasks.length} tasks from Firestore');

      for (final remote in remoteTasks) {
        try {
          final local = await taskLocalDataSource.getTask(remote.id);

          if (local == null) {
            // New record — insert locally
            final dataWithSync = _withSyncStatus(remote.toJson(), 'synced');
            final syncedModel = TaskModel.fromJson(dataWithSync);
            await taskLocalDataSource.insertTask(syncedModel);
            downloadCount++;
            await _logSyncHistory(
              tableName: 'tasks',
              recordId: remote.id,
              operation: 'download',
              status: 'completed',
              syncType: 'download',
            );
            log('SyncService: Downloaded new task ${remote.id}');
          } else {
            // Exists locally — compare timestamps
            final remoteUpdated = _getUpdatedAt(remote.toJson());
            final localUpdated = _getUpdatedAt(local.toJson());

            if (remoteUpdated > localUpdated) {
              // Remote is newer — update local
              final dataWithSync = _withSyncStatus(remote.toJson(), 'synced');
              final syncedModel = TaskModel.fromJson(dataWithSync);
              await taskLocalDataSource.updateTask(syncedModel);
              await _updateRecordSyncStatus('tasks', remote.id, 'synced');
              downloadCount++;
              await _logSyncHistory(
                tableName: 'tasks',
                recordId: remote.id,
                operation: 'download',
                status: 'completed',
                syncType: 'download',
              );
              log('SyncService: Updated task ${remote.id} (remote is newer)');
            }
          }
        } catch (e) {
          log('SyncService: Failed to merge task ${remote.id}: $e');
        }
      }
    } catch (e) {
      log('SyncService: Error downloading from Firestore: $e');
    }

    return downloadCount;
  }

  /// Process all pending operations in the sync queue
  /// Returns the number of successfully processed operations
  Future<int> processQueue() async {
    if (!await networkInfo.isConnected) {
      log('SyncService: No network connection, skipping queue...');
      return 0;
    }

    int successCount = 0;

    try {
      final pendingOps = await syncQueue.getPendingOperations();
      log('SyncService: Processing ${pendingOps.length} pending operations...');

      for (final op in pendingOps) {
        try {
          if (!await networkInfo.isConnected) {
            log('SyncService: Lost network connection, stopping...');
            break;
          }

          await _processOperation(op.id, op.tableName, op.operationType, op.jsonData, op.recordId);
          await syncQueue.markAsCompleted(op.id);
          await _updateRecordSyncStatus(op.tableName, op.recordId, 'synced');
          await _logSyncHistory(
            tableName: op.tableName,
            recordId: op.recordId,
            operation: op.operationType,
            status: 'completed',
          );
          successCount++;
        } catch (e) {
          await syncQueue.incrementRetry(op.id);

          if (!op.canRetry) {
            await syncQueue.markAsFailed(op.id, e.toString());
            await _updateRecordSyncStatus(op.tableName, op.recordId, 'conflict');
            await _logSyncHistory(
              tableName: op.tableName,
              recordId: op.recordId,
              operation: op.operationType,
              status: 'failed',
              error: e.toString(),
            );
            log('SyncService: Operation ${op.id} permanently failed: $e');
          } else {
            log('SyncService: Operation ${op.id} failed, will retry (${op.retryCount + 1}/${op.maxRetries}): $e');
          }
        }
      }

      await syncQueue.clearCompleted();
      log('SyncService: Queue processing complete. $successCount/${pendingOps.length} succeeded.');
    } catch (e) {
      log('SyncService: Error processing queue: $e');
    }

    return successCount;
  }

  /// Sync records that have pending sync_status in local tables
  Future<void> syncPendingRecords() async {
    if (!await networkInfo.isConnected) return;

    try {
      final pendingSubjects = await subjectLocalDataSource.getSubjectsBySyncStatus('pending');
      for (final subject in pendingSubjects) {
        try {
          await subjectRemoteDataSource.addSubject(subject);
          await _updateRecordSyncStatus('subjects', subject.id, 'synced');
          log('SyncService: Synced pending subject ${subject.id}');
        } catch (e) {
          log('SyncService: Failed to sync pending subject ${subject.id}: $e');
        }
      }

      final pendingTasks = await taskLocalDataSource.getTasksBySyncStatus('pending');
      for (final task in pendingTasks) {
        try {
          await taskRemoteDataSource.addTask(task);
          await _updateRecordSyncStatus('tasks', task.id, 'synced');
          log('SyncService: Synced pending task ${task.id}');
        } catch (e) {
          log('SyncService: Failed to sync pending task ${task.id}: $e');
        }
      }
    } catch (e) {
      log('SyncService: Error syncing pending records: $e');
    }
  }

  // ─── Private helpers ──────────────────────────────────────

  /// Extract updated_at timestamp from JSON (supports both int and missing)
  int _getUpdatedAt(Map<String, dynamic> json) {
    final val = json['updated_at'];
    if (val is int) return val;
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  /// Set sync_status on a JSON map
  Map<String, dynamic> _withSyncStatus(Map<String, dynamic> json, String status) {
    final copy = Map<String, dynamic>.from(json);
    copy['sync_status'] = status;
    return copy;
  }

  Future<void> _processOperation(
    String opId,
    String tableName,
    String operationType,
    String? jsonData,
    String recordId,
  ) async {
    switch (tableName) {
      case 'subjects':
        await _processSubjectOperation(operationType, jsonData, recordId);
        break;
      case 'tasks':
        await _processTaskOperation(operationType, jsonData, recordId);
        break;
      default:
        log('SyncService: Unknown table $tableName for operation $opId');
    }
  }

  Future<void> _processSubjectOperation(
    String operationType,
    String? jsonData,
    String recordId,
  ) async {
    switch (operationType) {
      case 'create':
      case 'update':
        if (jsonData == null) {
          throw Exception('No JSON data for subject $operationType');
        }
        final data = json.decode(jsonData) as Map<String, dynamic>;
        final model = SubjectModel.fromJson(data);
        if (operationType == 'create') {
          await subjectRemoteDataSource.addSubject(model);
        } else {
          await subjectRemoteDataSource.updateSubject(model);
        }
        break;
      case 'delete':
        await subjectRemoteDataSource.deleteSubject(recordId);
        break;
    }
  }

  Future<void> _processTaskOperation(
    String operationType,
    String? jsonData,
    String recordId,
  ) async {
    switch (operationType) {
      case 'create':
      case 'update':
        if (jsonData == null) {
          throw Exception('No JSON data for task $operationType');
        }
        final data = json.decode(jsonData) as Map<String, dynamic>;
        final model = TaskModel.fromJson(data);
        if (operationType == 'create') {
          await taskRemoteDataSource.addTask(model);
        } else {
          await taskRemoteDataSource.updateTask(model);
        }
        break;
      case 'delete':
        await taskRemoteDataSource.deleteTask(recordId);
        break;
    }
  }

  Future<void> _updateRecordSyncStatus(
    String tableName,
    String recordId,
    String status,
  ) async {
    try {
      final db = await databaseHelper.database;
      final idColumn = _getIdColumn(tableName);
      await db.update(
        tableName,
        {
          'sync_status': status,
          'last_sync': DateTime.now().millisecondsSinceEpoch,
        },
        where: '$idColumn = ?',
        whereArgs: [recordId],
      );
    } catch (e) {
      log('SyncService: Failed to update sync status for $tableName/$recordId: $e');
    }
  }

  Future<void> _logSyncHistory({
    required String tableName,
    required String recordId,
    required String operation,
    required String status,
    String? error,
    String syncType = 'upload',
  }) async {
    try {
      final db = await databaseHelper.database;
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('sync_history', {
        'sync_id': '${tableName}_${recordId}_$now',
        'user_id': 'system',
        'sync_type': syncType,
        'entity_type': tableName,
        'entity_id': recordId,
        'operation': operation,
        'status': status,
        'started_at': now,
        'completed_at': status == 'completed' ? now : null,
        'error_message': error,
        'retry_count': 0,
      });
    } catch (e) {
      log('SyncService: Failed to log sync history: $e');
    }
  }

  String _getIdColumn(String tableName) {
    switch (tableName) {
      case 'subjects':
        return 'subject_id';
      case 'tasks':
        return 'task_id';
      case 'attachments':
        return 'attachment_id';
      case 'grades':
        return 'grade_id';
      case 'calendar_events':
        return 'event_id';
      default:
        return 'id';
    }
  }

  /// Get the count of pending sync operations
  Future<int> getPendingCount() async {
    return await syncQueue.getPendingCount();
  }
}
