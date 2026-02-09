import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/task_local_data_source.dart';
import '../models/task_model.dart';
import '../../core/error/exceptions.dart';

/// Implementation of TaskRepository using local data source
class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl({required this.localDataSource});

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
      await localDataSource.insertTask(taskModel);
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
      await localDataSource.updateTask(taskModel);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to update task: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await localDataSource.deleteTask(taskId);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to delete task: ${e.toString()}');
    }
  }

  /// Get pending tasks for a user
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
  Future<void> markTaskAsCompleted(String taskId) async {
    try {
      await localDataSource.markTaskAsCompleted(taskId);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to mark task as completed: ${e.toString()}');
    }
  }

  /// Get a task by ID
  Future<Task?> getTaskById(String taskId) async {
    try {
      return await localDataSource.getTask(taskId);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to get task: ${e.toString()}');
    }
  }
}
