import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_entity.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/datasources/local/task_local_data_source.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/network/network_info.dart';
import '../../core/services/notification_service.dart';
import '../../data/datasources/remote/task_remote_data_source.dart';
import 'subject_notifier.dart';
import 'sync_provider.dart';
import 'sprint6_providers.dart';

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
  final NotificationService notificationService;
  String? _currentUserId;

  TaskNotifier(this.repository, this.notificationService)
      : super(const TaskState());

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

  /// Add a new task and schedule notifications if it has a due date
  Future<bool> addTask(Task task) async {
    try {
      await repository.addTask(task);

      // Schedule notification reminders if task has a due date
      if (task.dueDate != null && task.dueDate!.isAfter(DateTime.now())) {
        await notificationService.scheduleTaskReminders(
          taskId: task.id,
          taskTitle: task.title,
          dueDate: task.dueDate!,
        );
      }

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

  /// Update a task and reschedule notifications
  Future<bool> updateTask(Task task) async {
    try {
      await repository.updateTask(task);

      // Cancel old reminders and reschedule if due date exists
      await notificationService.cancelTaskReminders(task.id);
      if (task.dueDate != null &&
          task.dueDate!.isAfter(DateTime.now()) &&
          task.status != 'completed') {
        await notificationService.scheduleTaskReminders(
          taskId: task.id,
          taskTitle: task.title,
          dueDate: task.dueDate!,
        );
      }

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

  /// Delete a task and cancel its notifications
  Future<bool> deleteTask(String taskId) async {
    try {
      // Cancel reminders before deleting
      await notificationService.cancelTaskReminders(taskId);
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

  /// Mark a task as completed and cancel its notifications
  Future<bool> completeTask(String taskId) async {
    try {
      await notificationService.cancelTaskReminders(taskId);
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

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
});

final taskRepositoryProvider = Provider<TaskRepositoryImpl>((ref) {
  return TaskRepositoryImpl(
    localDataSource: ref.watch(taskLocalDataSourceProvider),
    remoteDataSource: ref.watch(taskRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
    syncQueue: ref.watch(syncQueueDataSourceProvider),
  );
});

final taskNotifierProvider = StateNotifierProvider<TaskNotifier, TaskState>((
  ref,
) {
  return TaskNotifier(
    ref.watch(taskRepositoryProvider),
    ref.watch(notificationServiceProvider),
  );
});
