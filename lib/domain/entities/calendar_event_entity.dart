import 'package:equatable/equatable.dart';

class CalendarEvent extends Equatable {
  final String id;
  final String userId;
  final String? subjectId;
  final String? taskId;
  final String eventType;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final String? location;
  final bool isAllDay;
  final String? color;
  final String? recurrenceRule;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final String? serverId;

  const CalendarEvent({
    required this.id,
    required this.userId,
    this.subjectId,
    this.taskId,
    required this.eventType,
    required this.title,
    this.description,
    required this.startDate,
    this.endDate,
    this.location,
    this.isAllDay = false,
    this.color,
    this.recurrenceRule,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'synced',
    this.serverId,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    subjectId,
    taskId,
    eventType,
    title,
    description,
    startDate,
    endDate,
    location,
    isAllDay,
    color,
    recurrenceRule,
    createdAt,
    updatedAt,
    syncStatus,
    serverId,
  ];
}
