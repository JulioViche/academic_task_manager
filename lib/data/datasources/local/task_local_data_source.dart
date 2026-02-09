import 'package:sqflite/sqflite.dart';
import '../../models/task_model.dart';
import '../../../core/error/exceptions.dart';
import 'database_helper.dart';

/// Local data source for Task CRUD operations using SQLite
abstract class TaskLocalDataSource {
  /// Get all tasks for a user
  Future<List<TaskModel>> getAllTasks(String userId);

  /// Get tasks for a specific subject
  Future<List<TaskModel>> getTasksBySubject(String subjectId);

  /// Get pending tasks for a user
  Future<List<TaskModel>> getPendingTasks(String userId);

  /// Get overdue tasks for a user
  Future<List<TaskModel>> getOverdueTasks(String userId);

  /// Get a task by ID
  Future<TaskModel?> getTask(String taskId);

  /// Insert a new task
  Future<void> insertTask(TaskModel task);

  /// Update an existing task
  Future<void> updateTask(TaskModel task);

  /// Delete a task
  Future<void> deleteTask(String taskId);

  /// Mark a task as completed
  Future<void> markTaskAsCompleted(String taskId);

  /// Get tasks by sync status
  Future<List<TaskModel>> getTasksBySyncStatus(String syncStatus);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final DatabaseHelper databaseHelper;

  TaskLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<TaskModel>> getAllTasks(String userId) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'due_date ASC, priority DESC',
      );

      return maps.map((map) => TaskModel.fromJson(map)).toList();
    } catch (e) {
      throw CacheException('Failed to get tasks: ${e.toString()}');
    }
  }

  @override
  Future<List<TaskModel>> getTasksBySubject(String subjectId) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'subject_id = ?',
        whereArgs: [subjectId],
        orderBy: 'due_date ASC',
      );

      return maps.map((map) => TaskModel.fromJson(map)).toList();
    } catch (e) {
      throw CacheException('Failed to get tasks by subject: ${e.toString()}');
    }
  }

  @override
  Future<List<TaskModel>> getPendingTasks(String userId) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'user_id = ? AND status IN (?, ?)',
        whereArgs: [userId, 'pending', 'in_progress'],
        orderBy: 'due_date ASC, priority DESC',
      );

      return maps.map((map) => TaskModel.fromJson(map)).toList();
    } catch (e) {
      throw CacheException('Failed to get pending tasks: ${e.toString()}');
    }
  }

  @override
  Future<List<TaskModel>> getOverdueTasks(String userId) async {
    try {
      final db = await databaseHelper.database;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'user_id = ? AND due_date < ? AND status != ?',
        whereArgs: [userId, now, 'completed'],
        orderBy: 'due_date ASC',
      );

      return maps.map((map) => TaskModel.fromJson(map)).toList();
    } catch (e) {
      throw CacheException('Failed to get overdue tasks: ${e.toString()}');
    }
  }

  @override
  Future<TaskModel?> getTask(String taskId) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'task_id = ?',
        whereArgs: [taskId],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return TaskModel.fromJson(maps.first);
    } catch (e) {
      throw CacheException('Failed to get task: ${e.toString()}');
    }
  }

  @override
  Future<void> insertTask(TaskModel task) async {
    try {
      final db = await databaseHelper.database;
      
      await db.insert(
        'tasks',
        task.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException('Failed to insert task: ${e.toString()}');
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      final db = await databaseHelper.database;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      final data = task.toJson();
      data['updated_at'] = now;
      data['sync_status'] = 'pending';
      
      await db.update(
        'tasks',
        data,
        where: 'task_id = ?',
        whereArgs: [task.id],
      );
    } catch (e) {
      throw CacheException('Failed to update task: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        'tasks',
        where: 'task_id = ?',
        whereArgs: [taskId],
      );
    } catch (e) {
      throw CacheException('Failed to delete task: ${e.toString()}');
    }
  }

  @override
  Future<void> markTaskAsCompleted(String taskId) async {
    try {
      final db = await databaseHelper.database;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      await db.update(
        'tasks',
        {
          'status': 'completed',
          'completed_at': now,
          'updated_at': now,
          'sync_status': 'pending',
        },
        where: 'task_id = ?',
        whereArgs: [taskId],
      );
    } catch (e) {
      throw CacheException('Failed to mark task as completed: ${e.toString()}');
    }
  }

  @override
  Future<List<TaskModel>> getTasksBySyncStatus(String syncStatus) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'sync_status = ?',
        whereArgs: [syncStatus],
      );

      return maps.map((map) => TaskModel.fromJson(map)).toList();
    } catch (e) {
      throw CacheException('Failed to get tasks by sync status: ${e.toString()}');
    }
  }
}
