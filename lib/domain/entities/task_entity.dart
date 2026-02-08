import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String id;
  final String subjectId;
  final String userId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String priority;
  final String status;
  final double? grade;
  final double maxGrade;
  final double weight;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final String syncStatus;
  final String? serverId;

  const Task({
    required this.id,
    required this.subjectId,
    required this.userId,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 'medium',
    this.status = 'pending',
    this.grade,
    this.maxGrade = 10.0,
    this.weight = 1.0,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.syncStatus = 'synced',
    this.serverId,
  });

  @override
  List<Object?> get props => [
    id,
    subjectId,
    userId,
    title,
    description,
    dueDate,
    priority,
    status,
    grade,
    maxGrade,
    weight,
    createdAt,
    updatedAt,
    completedAt,
    syncStatus,
    serverId,
  ];
}
