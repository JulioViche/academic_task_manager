import 'package:equatable/equatable.dart';

class Subject extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? code; // Keep this as nullable
  final String description;
  final String colorHex;
  final String teacherName;
  final String? serverId; // Add serverId
  final String? color; // Add color
  final String? semester; // Add semester
  final String? professorName; // Add professorName
  final String? schedule; // Add schedule
  final bool isArchived; // Add isArchived
  final String syncStatus; // Add syncStatus

  const Subject({
    required this.id,
    required this.userId,
    required this.name,
    this.code, // Make code nullable in constructor
    this.description = '',
    this.colorHex = '#2196F3',
    this.teacherName = '',
    this.color, // Add color to constructor
    this.semester, // Add semester to constructor
    this.professorName, // Add professorName to constructor
    this.schedule, // Add schedule to constructor
    this.isArchived = false, // Add isArchived to constructor
    this.syncStatus = 'synced', // Add syncStatus to constructor
    this.serverId, // Add serverId to constructor
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    code,
    description,
    color,
    semester,
    professorName,
    schedule,
    isArchived,
    syncStatus,
    serverId,
    colorHex,
    teacherName,
  ];
}
