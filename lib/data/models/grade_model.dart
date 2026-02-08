import '../../domain/entities/grade_entity.dart';

class GradeModel extends Grade {
  const GradeModel({
    required super.id,
    required super.subjectId,
    required super.userId,
    required super.gradeType,
    required super.gradeName,
    required super.score,
    required super.maxScore,
    super.percentage,
    super.weight,
    required super.date,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    super.serverId,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json['grade_id'],
      subjectId: json['subject_id'],
      userId: json['user_id'],
      gradeType: json['grade_type'],
      gradeName: json['grade_name'],
      score: json['score'],
      maxScore: json['max_score'],
      percentage: json['percentage'],
      weight: json['weight'] ?? 1.0,
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      notes: json['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updated_at']),
      syncStatus: json['sync_status'] ?? 'synced',
      serverId: json['server_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grade_id': id,
      'subject_id': subjectId,
      'user_id': userId,
      'grade_type': gradeType,
      'grade_name': gradeName,
      'score': score,
      'max_score': maxScore,
      'percentage': percentage,
      'weight': weight,
      'date': date.millisecondsSinceEpoch,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'sync_status': syncStatus,
      'server_id': serverId,
    };
  }

  factory GradeModel.fromEntity(Grade grade) {
    return GradeModel(
      id: grade.id,
      subjectId: grade.subjectId,
      userId: grade.userId,
      gradeType: grade.gradeType,
      gradeName: grade.gradeName,
      score: grade.score,
      maxScore: grade.maxScore,
      percentage: grade.percentage,
      weight: grade.weight,
      date: grade.date,
      notes: grade.notes,
      createdAt: grade.createdAt,
      updatedAt: grade.updatedAt,
      syncStatus: grade.syncStatus,
      serverId: grade.serverId,
    );
  }
}
