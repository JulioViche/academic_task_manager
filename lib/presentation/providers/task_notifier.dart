import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_entity.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/datasources/local/task_local_data_source.dart';
import 'subject_notifier.dart';

/// State for tasks
class TaskState {
  final List<Task> tasks;
  final List<Task> pendingTasks;
  final List<Task> overdueTasks;
  final bool isLoading;
  final String? errorMessage;

  const TaskState({
    this.tasks = const [],
    this.pendingTasks = const [],
    this.overdueTasks = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  TaskState copyWith({
    List<Task>? tasks,
    List<Task>? pendingTasks,
    List<Task>? overdueTasks,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      pendingTasks: pendingTasks ?? this.pendingTasks,
      overdueTasks: overdueTasks ?? this.overdueTasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Task state notifier
class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepositoryImpl repository;
  String? _currentUserId;

  TaskNotifier(this.repository) : super(const TaskState());

  /// Load all tasks for a user
  Future<void> loadTasks(String userId) async {
    _currentUserId = userId;
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final tasks = await repository.getTasks(userId);
      final pendingTasks = await repository.getPendingTasks(userId);
      final overdueTasks = await repository.getOverdueTasks(userId);
      
      state = state.copyWith(
        tasks: tasks,
        pendingTasks: pendingTasks,
        overdueTasks: overdueTasks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load tasks: ${e.toString()}',
      );
    }
  }

  /// Get tasks for a specific subject
  Future<List<Task>> getTasksBySubject(String subjectId) async {
    try {
      return await repository.getTasksBySubject(subjectId);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to get tasks: ${e.toString()}',
      );
      return [];
    }
  }

  /// Add a new task
  Future<bool> addTask(Task task) async {
    try {
      await repository.addTask(task);
      if (_currentUserId != null) {
        await loadTasks(_currentUserId!);
      }
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to add task: ${e.toString()}',
      );
      return false;
    }
  }

  /// Update a task
  Future<bool> updateTask(Task task) async {
    try {
      await repository.updateTask(task);
      if (_currentUserId != null) {
        await loadTasks(_currentUserId!);
      }
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to update task: ${e.toString()}',
      );
      return false;
    }
  }

  /// Delete a task
  Future<bool> deleteTask(String taskId) async {
    try {
      await repository.deleteTask(taskId);
      if (_currentUserId != null) {
        await loadTasks(_currentUserId!);
      }
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to delete task: ${e.toString()}',
      );
      return false;
    }
  }

  /// Mark a task as completed
  Future<bool> completeTask(String taskId) async {
    try {
      await repository.markTaskAsCompleted(taskId);
      if (_currentUserId != null) {
        await loadTasks(_currentUserId!);
      }
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to complete task: ${e.toString()}',
      );
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Providers
final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  return TaskLocalDataSourceImpl(
    databaseHelper: ref.watch(databaseHelperProvider),
  );
});

final taskRepositoryProvider = Provider<TaskRepositoryImpl>((ref) {
  return TaskRepositoryImpl(
    localDataSource: ref.watch(taskLocalDataSourceProvider),
  );
});

final taskNotifierProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier(ref.watch(taskRepositoryProvider));
});
