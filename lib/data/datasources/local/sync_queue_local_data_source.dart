import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import '../../models/sync_operation_model.dart';
import '../../../core/error/exceptions.dart';
import 'database_helper.dart';

/// Local data source for managing the sync operation queue
abstract class SyncQueueLocalDataSource {
  /// Add an operation to the sync queue
  Future<void> addToQueue(SyncOperationModel operation);

  /// Get all pending operations ordered by creation date (FIFO)
  Future<List<SyncOperationModel>> getPendingOperations();

  /// Mark an operation as completed
  Future<void> markAsCompleted(String operationId);

  /// Mark an operation as failed with error message
  Future<void> markAsFailed(String operationId, String errorMessage);

  /// Increment retry count and update last attempted time
  Future<void> incrementRetry(String operationId);

  /// Remove all completed operations
  Future<void> clearCompleted();

  /// Get count of pending operations
  Future<int> getPendingCount();

  /// Check if a record already has a pending operation
  Future<bool> hasExistingOperation(String recordId, String tableName);

  /// Remove operations for a specific record (e.g., after successful direct sync)
  Future<void> removeOperationsForRecord(String recordId, String tableName);
}

class SyncQueueLocalDataSourceImpl implements SyncQueueLocalDataSource {
  final DatabaseHelper databaseHelper;

  SyncQueueLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<void> addToQueue(SyncOperationModel operation) async {
    try {
      final db = await databaseHelper.database;

      // If there's already a pending operation for this record, update it
      final existing = await db.query(
        'sync_queue',
        where: 'record_id = ? AND table_name = ? AND status = ?',
        whereArgs: [operation.recordId, operation.tableName, 'pending'],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        // Update existing operation with new data
        await db.update(
          'sync_queue',
          {
            'operation_type': operation.operationType,
            'json_data': operation.jsonData,
            'created_at': DateTime.now().millisecondsSinceEpoch,
            'retry_count': 0,
            'error_message': null,
          },
          where: 'id = ?',
          whereArgs: [existing.first['id']],
        );
        log('SyncQueue: Updated existing operation for ${operation.tableName}/${operation.recordId}');
      } else {
        await db.insert(
          'sync_queue',
          operation.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        log('SyncQueue: Added ${operation.operationType} for ${operation.tableName}/${operation.recordId}');
      }
    } catch (e) {
      throw CacheException('Failed to add to sync queue: ${e.toString()}');
    }
  }

  @override
  Future<List<SyncOperationModel>> getPendingOperations() async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sync_queue',
        where: 'status = ? AND retry_count < max_retries',
        whereArgs: ['pending'],
        orderBy: 'created_at ASC',
      );

      return maps.map((map) => SyncOperationModel.fromJson(map)).toList();
    } catch (e) {
      throw CacheException(
        'Failed to get pending operations: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> markAsCompleted(String operationId) async {
    try {
      final db = await databaseHelper.database;
      await db.update(
        'sync_queue',
        {
          'status': 'completed',
          'last_attempted_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [operationId],
      );
      log('SyncQueue: Marked $operationId as completed');
    } catch (e) {
      throw CacheException(
        'Failed to mark operation as completed: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> markAsFailed(String operationId, String errorMessage) async {
    try {
      final db = await databaseHelper.database;
      await db.update(
        'sync_queue',
        {
          'status': 'failed',
          'error_message': errorMessage,
          'last_attempted_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [operationId],
      );
      log('SyncQueue: Marked $operationId as failed: $errorMessage');
    } catch (e) {
      throw CacheException(
        'Failed to mark operation as failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> incrementRetry(String operationId) async {
    try {
      final db = await databaseHelper.database;
      await db.rawUpdate(
        'UPDATE sync_queue SET retry_count = retry_count + 1, last_attempted_at = ? WHERE id = ?',
        [DateTime.now().millisecondsSinceEpoch, operationId],
      );
    } catch (e) {
      throw CacheException(
        'Failed to increment retry count: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearCompleted() async {
    try {
      final db = await databaseHelper.database;
      final count = await db.delete(
        'sync_queue',
        where: 'status = ?',
        whereArgs: ['completed'],
      );
      log('SyncQueue: Cleared $count completed operations');
    } catch (e) {
      throw CacheException(
        'Failed to clear completed operations: ${e.toString()}',
      );
    }
  }

  @override
  Future<int> getPendingCount() async {
    try {
      final db = await databaseHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM sync_queue WHERE status = ?',
        ['pending'],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw CacheException(
        'Failed to get pending count: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> hasExistingOperation(String recordId, String tableName) async {
    try {
      final db = await databaseHelper.database;
      final result = await db.query(
        'sync_queue',
        where: 'record_id = ? AND table_name = ? AND status = ?',
        whereArgs: [recordId, tableName, 'pending'],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      throw CacheException(
        'Failed to check existing operation: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> removeOperationsForRecord(
    String recordId,
    String tableName,
  ) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        'sync_queue',
        where: 'record_id = ? AND table_name = ?',
        whereArgs: [recordId, tableName],
      );
    } catch (e) {
      throw CacheException(
        'Failed to remove operations for record: ${e.toString()}',
      );
    }
  }
}
