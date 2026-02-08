import 'package:equatable/equatable.dart';

class Grade extends Equatable {
  final String id;
  final String subjectId;
  final String userId;
  final String gradeType;
  final String gradeName;
  final double score;
  final double maxScore;
  final double? percentage;
  final double weight;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final String? serverId;

  const Grade({
    required this.id,
    required this.subjectId,
    required this.userId,
    required this.gradeType,
    required this.gradeName,
    required this.score,
    required this.maxScore,
    this.percentage,
    this.weight = 1.0,
    required this.date,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'synced',
    this.serverId,
  });

  @override
  List<Object?> get props => [
    id,
    subjectId,
    userId,
    gradeType,
    gradeName,
    score,
    maxScore,
    percentage,
    weight,
    date,
    notes,
    createdAt,
    updatedAt,
    syncStatus,
    serverId,
  ];
}
