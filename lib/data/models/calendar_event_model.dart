import '../../domain/entities/calendar_event_entity.dart';

class CalendarEventModel extends CalendarEvent {
  const CalendarEventModel({
    required super.id,
    required super.userId,
    super.subjectId,
    super.taskId,
    required super.eventType,
    required super.title,
    super.description,
    required super.startDate,
    super.endDate,
    super.location,
    super.isAllDay,
    super.color,
    super.recurrenceRule,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    super.serverId,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['event_id'],
      userId: json['user_id'],
      subjectId: json['subject_id'],
      taskId: json['task_id'],
      eventType: json['event_type'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.fromMillisecondsSinceEpoch(json['start_date']),
      endDate: json['end_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['end_date'])
          : null,
      location: json['location'],
      isAllDay: json['is_all_day'] == 1,
      color: json['color'],
      recurrenceRule: json['recurrence_rule'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updated_at']),
      syncStatus: json['sync_status'] ?? 'synced',
      serverId: json['server_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': id,
      'user_id': userId,
      'subject_id': subjectId,
      'task_id': taskId,
      'event_type': eventType,
      'title': title,
      'description': description,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate?.millisecondsSinceEpoch,
      'location': location,
      'is_all_day': isAllDay ? 1 : 0,
      'color': color,
      'recurrence_rule': recurrenceRule,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'sync_status': syncStatus,
      'server_id': serverId,
    };
  }

  factory CalendarEventModel.fromEntity(CalendarEvent event) {
    return CalendarEventModel(
      id: event.id,
      userId: event.userId,
      subjectId: event.subjectId,
      taskId: event.taskId,
      eventType: event.eventType,
      title: event.title,
      description: event.description,
      startDate: event.startDate,
      endDate: event.endDate,
      location: event.location,
      isAllDay: event.isAllDay,
      color: event.color,
      recurrenceRule: event.recurrenceRule,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
      syncStatus: event.syncStatus,
      serverId: event.serverId,
    );
  }
}
