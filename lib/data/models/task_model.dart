import '../../domain/entities/task_entity.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.subjectId,
    required super.userId,
    required super.title,
    super.description,
    super.dueDate,
    super.priority,
    super.status,
    super.grade,
    super.maxGrade,
    super.weight,
    required super.createdAt,
    required super.updatedAt,
    super.completedAt,
    super.syncStatus,
    super.serverId,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['task_id'],
      subjectId: json['subject_id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['due_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['due_date'])
          : null,
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'pending',
      grade: json['grade'],
      maxGrade: json['max_grade'] ?? 10.0,
      weight: json['weight'] ?? 1.0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updated_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completed_at'])
          : null,
      syncStatus: json['sync_status'] ?? 'synced',
      serverId: json['server_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': id,
      'subject_id': subjectId,
      'user_id': userId,
      'title': title,
      'description': description,
      'due_date': dueDate?.millisecondsSinceEpoch,
      'priority': priority,
      'status': status,
      'grade': grade,
      'max_grade': maxGrade,
      'weight': weight,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'completed_at': completedAt?.millisecondsSinceEpoch,
      'sync_status': syncStatus,
      'server_id': serverId,
    };
  }

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      subjectId: task.subjectId,
      userId: task.userId,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority,
      status: task.status,
      grade: task.grade,
      maxGrade: task.maxGrade,
      weight: task.weight,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      completedAt: task.completedAt,
      syncStatus: task.syncStatus,
      serverId: task.serverId,
    );
  }
}
