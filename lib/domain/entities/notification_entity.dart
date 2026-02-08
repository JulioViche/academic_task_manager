import 'package:equatable/equatable.dart';

class Notification extends Equatable {
  final String id;
  final String userId;
  final String? taskId;
  final String? eventId;
  final String notificationType;
  final String title;
  final String? body;
  final DateTime? scheduledTime;
  final DateTime? sentAt;
  final bool isRead;
  final bool isSent;
  final String priority;
  final String? actionType;
  final String? actionData;
  final DateTime createdAt;
  final String syncStatus;
  final String? serverId;

  const Notification({
    required this.id,
    required this.userId,
    this.taskId,
    this.eventId,
    required this.notificationType,
    required this.title,
    this.body,
    this.scheduledTime,
    this.sentAt,
    this.isRead = false,
    this.isSent = false,
    this.priority = 'default',
    this.actionType,
    this.actionData,
    required this.createdAt,
    this.syncStatus = 'synced',
    this.serverId,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    taskId,
    eventId,
    notificationType,
    title,
    body,
    scheduledTime,
    sentAt,
    isRead,
    isSent,
    priority,
    actionType,
    actionData,
    createdAt,
    syncStatus,
    serverId,
  ];
}
