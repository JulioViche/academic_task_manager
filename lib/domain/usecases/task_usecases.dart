import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// Get all tasks for a user
class GetTasksUseCase {
  final TaskRepository repository;

  GetTasksUseCase(this.repository);

  Future<List<Task>> call(String userId) async {
    return repository.getTasks(userId);
  }
}

/// Get tasks for a specific subject
class GetTasksBySubjectUseCase {
  final TaskRepository repository;

  GetTasksBySubjectUseCase(this.repository);

  Future<List<Task>> call(String subjectId) async {
    return repository.getTasksBySubject(subjectId);
  }
}

/// Add a new task
class AddTaskUseCase {
  final TaskRepository repository;

  AddTaskUseCase(this.repository);

  Future<void> call(Task task) async {
    return repository.addTask(task);
  }
}

/// Update an existing task
class UpdateTaskUseCase {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  Future<void> call(Task task) async {
    return repository.updateTask(task);
  }
}

/// Delete a task
class DeleteTaskUseCase {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  Future<void> call(String taskId) async {
    return repository.deleteTask(taskId);
  }
}
