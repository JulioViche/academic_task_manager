import 'dart:convert';
import 'dart:developer';
import '../../core/network/network_info.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/task_local_data_source.dart';
import '../datasources/local/sync_queue_local_data_source.dart';
import '../datasources/remote/task_remote_data_source.dart';
import '../models/task_model.dart';
import '../models/sync_operation_model.dart';
import '../../core/error/exceptions.dart';

/// Implementation of TaskRepository using local and remote data sources
class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final SyncQueueLocalDataSource syncQueue;

  TaskRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.syncQueue,
  });

  @override
  Future<List<Task>> getTasks(String userId) async {
    try {
      final tasks = await localDataSource.getAllTasks(userId);
      return tasks;
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to get tasks: ${e.toString()}');
    }
  }

  @override
  Future<List<Task>> getTasksBySubject(String subjectId) async {
    try {
      final tasks = await localDataSource.getTasksBySubject(subjectId);
      return tasks;
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to get tasks by subject: ${e.toString()}');
    }
  }

  @override
  Future<void> addTask(Task task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);

      // 1. Save to Local DB
      await localDataSource.insertTask(taskModel);

      // 2. Try to sync to Remote DB
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.addTask(taskModel);
        } catch (e) {
          log('Failed to sync addTask to remote, queuing: $e');
          await _enqueueOperation('create', taskModel);
        }
      } else {
        await _enqueueOperation('create', taskModel);
      }
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to add task: ${e.toString()}');
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);

      // 1. Update Local DB
      await localDataSource.updateTask(taskModel);

      // 2. Try to sync to Remote DB
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.updateTask(taskModel);
        } catch (e) {
          log('Failed to sync updateTask to remote, queuing: $e');
          await _enqueueOperation('update', taskModel);
        }
      } else {
        await _enqueueOperation('update', taskModel);
      }
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to update task: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      // 1. Delete from Local DB
      await localDataSource.deleteTask(taskId);

      // 2. Try to sync to Remote DB
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.deleteTask(taskId);
        } catch (e) {
          log('Failed to sync deleteTask to remote, queuing: $e');
          await _enqueueDeleteOperation(taskId);
        }
      } else {
        await _enqueueDeleteOperation(taskId);
      }
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to delete task: ${e.toString()}');
    }
  }

  /// Get pending tasks for a user
  @override
  Future<List<Task>> getPendingTasks(String userId) async {
    try {
      return await localDataSource.getPendingTasks(userId);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to get pending tasks: ${e.toString()}');
    }
  }

  /// Get overdue tasks for a user
  @override
  Future<List<Task>> getOverdueTasks(String userId) async {
    try {
      return await localDataSource.getOverdueTasks(userId);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to get overdue tasks: ${e.toString()}');
    }
  }

  /// Mark a task as completed
  @override
  Future<void> markTaskAsCompleted(String taskId) async {
    try {
      await localDataSource.markTaskAsCompleted(taskId);

      // Sync completion status to remote
      if (await networkInfo.isConnected) {
        try {
          final task = await localDataSource.getTask(taskId);
          if (task != null) {
            await remoteDataSource.updateTask(task);
          }
        } catch (e) {
          log('Failed to sync markTaskAsCompleted to remote, queuing: $e');
          final task = await localDataSource.getTask(taskId);
          if (task != null) {
            await _enqueueOperation('update', task);
          }
        }
      } else {
        final task = await localDataSource.getTask(taskId);
        if (task != null) {
          await _enqueueOperation('update', task);
        }
      }
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(
          'Failed to mark task as completed: ${e.toString()}');
    }
  }

  /// Get a task by ID
  @override
  Future<Task?> getTaskById(String taskId) async {
    try {
      return await localDataSource.getTask(taskId);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to get task: ${e.toString()}');
    }
  }

  /// Helper: enqueue a create/update operation for a task
  Future<void> _enqueueOperation(String type, TaskModel model) async {
    try {
      await syncQueue.addToQueue(SyncOperationModel.create(
        tableName: 'tasks',
        recordId: model.id,
        operationType: type,
        jsonData: json.encode(model.toJson()),
      ));
    } catch (e) {
      log('Failed to enqueue task operation: $e');
    }
  }

  /// Helper: enqueue a delete operation for a task
  Future<void> _enqueueDeleteOperation(String taskId) async {
    try {
      await syncQueue.addToQueue(SyncOperationModel.create(
        tableName: 'tasks',
        recordId: taskId,
        operationType: 'delete',
      ));
    } catch (e) {
      log('Failed to enqueue task delete operation: $e');
    }
  }
}
