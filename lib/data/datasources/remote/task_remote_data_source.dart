import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String taskId);
  Future<List<TaskModel>> getAllTasks(String userId);
  Future<List<TaskModel>> getTasksBySubject(String subjectId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;

  TaskRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> addTask(TaskModel task) async {
    try {
      await firestore.collection('tasks').doc(task.id).set(task.toJson());
    } catch (e) {
      throw Exception('Failed to add task to remote: $e');
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      await firestore.collection('tasks').doc(task.id).update(task.toJson());
    } catch (e) {
      throw Exception('Failed to update task in remote: $e');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task from remote: $e');
    }
  }

  @override
  Future<List<TaskModel>> getAllTasks(String userId) async {
    try {
      final snapshot = await firestore
          .collection('tasks')
          .where('user_id', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get tasks from remote: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksBySubject(String subjectId) async {
    try {
      final snapshot = await firestore
          .collection('tasks')
          .where('subject_id', isEqualTo: subjectId)
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get tasks by subject from remote: $e');
    }
  }
}
