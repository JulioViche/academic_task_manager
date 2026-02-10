import 'dart:convert';
import 'dart:developer';
import '../../data/datasources/local/sync_queue_local_data_source.dart';
import '../../data/datasources/local/subject_local_data_source.dart';
import '../../data/datasources/local/task_local_data_source.dart';
import '../../data/datasources/remote/subject_remote_data_source.dart';
import '../../data/datasources/remote/task_remote_data_source.dart';
import '../../data/models/subject_model.dart';
import '../../data/models/task_model.dart';
import '../../data/datasources/local/database_helper.dart';
import '../network/network_info.dart';

/// Possible states of the sync service
enum SyncStatus { idle, syncing, completed, error }

/// Central synchronization service that processes the sync queue
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

  /// Process all pending operations in the sync queue
  /// Returns the number of successfully processed operations
  Future<int> processQueue() async {
    if (_isSyncing) {
      log('SyncService: Already syncing, skipping...');
      return 0;
    }

    if (!await networkInfo.isConnected) {
      log('SyncService: No network connection, skipping...');
      return 0;
    }

    _isSyncing = true;
    int successCount = 0;

    try {
      final pendingOps = await syncQueue.getPendingOperations();
      log('SyncService: Processing ${pendingOps.length} pending operations...');

      for (final op in pendingOps) {
        try {
          // Check network before each operation
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
            log('SyncService: Operation ${op.id} permanently failed after max retries: $e');
          } else {
            log('SyncService: Operation ${op.id} failed, will retry (${op.retryCount + 1}/${op.maxRetries}): $e');
          }
        }
      }

      // Clean up completed operations
      await syncQueue.clearCompleted();
      log('SyncService: Queue processing complete. $successCount/${pendingOps.length} succeeded.');
    } catch (e) {
      log('SyncService: Error processing queue: $e');
    } finally {
      _isSyncing = false;
    }

    return successCount;
  }

  /// Sync records that have pending sync_status in local tables
  /// This catches records that may have been marked as pending but
  /// didn't get added to the sync queue (e.g., from older code paths)
  Future<void> syncPendingRecords() async {
    if (!await networkInfo.isConnected) return;

    try {
      // Sync pending subjects
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

      // Sync pending tasks
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

  /// Process a single sync operation
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

  /// Update the sync_status field on the original record
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

  /// Log a sync operation to the sync_history table
  Future<void> _logSyncHistory({
    required String tableName,
    required String recordId,
    required String operation,
    required String status,
    String? error,
  }) async {
    try {
      final db = await databaseHelper.database;
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('sync_history', {
        'sync_id': '${tableName}_${recordId}_$now',
        'user_id': 'system',
        'sync_type': 'upload',
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

  /// Get the primary key column name for a table
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
