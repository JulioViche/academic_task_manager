import '../../domain/entities/notification_entity.dart';

class NotificationModel extends Notification {
  const NotificationModel({
    required super.id,
    required super.userId,
    super.taskId,
    super.eventId,
    required super.notificationType,
    required super.title,
    super.body,
    super.scheduledTime,
    super.sentAt,
    super.isRead,
    super.isSent,
    super.priority,
    super.actionType,
    super.actionData,
    required super.createdAt,
    super.syncStatus,
    super.serverId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['notification_id'],
      userId: json['user_id'],
      taskId: json['task_id'],
      eventId: json['event_id'],
      notificationType: json['notification_type'],
      title: json['title'],
      body: json['body'],
      scheduledTime: json['scheduled_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['scheduled_time'])
          : null,
      sentAt: json['sent_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['sent_at'])
          : null,
      isRead: json['is_read'] == 1,
      isSent: json['is_sent'] == 1,
      priority: json['priority'] ?? 'default',
      actionType: json['action_type'],
      actionData: json['action_data'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      syncStatus: json['sync_status'] ?? 'synced',
      serverId: json['server_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': id,
      'user_id': userId,
      'task_id': taskId,
      'event_id': eventId,
      'notification_type': notificationType,
      'title': title,
      'body': body,
      'scheduled_time': scheduledTime?.millisecondsSinceEpoch,
      'sent_at': sentAt?.millisecondsSinceEpoch,
      'is_read': isRead ? 1 : 0,
      'is_sent': isSent ? 1 : 0,
      'priority': priority,
      'action_type': actionType,
      'action_data': actionData,
      'created_at': createdAt.millisecondsSinceEpoch,
      'sync_status': syncStatus,
      'server_id': serverId,
    };
  }

  factory NotificationModel.fromEntity(Notification notification) {
    return NotificationModel(
      id: notification.id,
      userId: notification.userId,
      taskId: notification.taskId,
      eventId: notification.eventId,
      notificationType: notification.notificationType,
      title: notification.title,
      body: notification.body,
      scheduledTime: notification.scheduledTime,
      sentAt: notification.sentAt,
      isRead: notification.isRead,
      isSent: notification.isSent,
      priority: notification.priority,
      actionType: notification.actionType,
      actionData: notification.actionData,
      createdAt: notification.createdAt,
      syncStatus: notification.syncStatus,
      serverId: notification.serverId,
    );
  }
}
