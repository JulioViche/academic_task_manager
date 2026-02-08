import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks(String userId);
  Future<List<Task>> getTasksBySubject(String subjectId);
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
}
