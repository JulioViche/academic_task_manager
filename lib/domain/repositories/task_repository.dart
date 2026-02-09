import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks(String userId);
  Future<List<Task>> getTasksBySubject(String subjectId);
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Future<List<Task>> getPendingTasks(String userId);
  Future<List<Task>> getOverdueTasks(String userId);
  Future<void> markTaskAsCompleted(String taskId);
  Future<Task?> getTaskById(String taskId);
}
