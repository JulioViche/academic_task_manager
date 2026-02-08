import 'package:equatable/equatable.dart';

class Subject extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? code;
  final String? description;
  final String? color;
  final String? semester;
  final String? professorName;
  final String? schedule;
  final bool isArchived;
  final String syncStatus;
  final String? serverId;

  const Subject({
    required this.id,
    required this.userId,
    required this.name,
    this.code,
    this.description,
    this.color,
    this.semester,
    this.professorName,
    this.schedule,
    this.isArchived = false,
    this.syncStatus = 'synced',
    this.serverId,
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
  ];
}
