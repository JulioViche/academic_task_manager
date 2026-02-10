import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/notification_local_data_source.dart';
import '../../data/models/notification_model.dart';
import '../../domain/entities/notification_entity.dart';
import 'package:uuid/uuid.dart';

// ─── State ──────────────────────────────────────────────

class NotificationState {
  final List<Notification> notifications;
  final int unreadCount;
  final bool isLoading;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
  });

  NotificationState copyWith({
    List<Notification>? notifications,
    int? unreadCount,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ─── Notifier ───────────────────────────────────────────

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationLocalDataSource dataSource;

  NotificationNotifier({required this.dataSource})
      : super(const NotificationState());

  Future<void> loadNotifications(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final notifications = await dataSource.getAllNotifications(userId);
      final unread = await dataSource.getUnreadCount(userId);
      state = state.copyWith(
        notifications: notifications,
        unreadCount: unread,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> markAsRead(String notificationId, String userId) async {
    await dataSource.markAsRead(notificationId);
    await loadNotifications(userId);
  }

  Future<void> deleteNotification(String notificationId, String userId) async {
    await dataSource.deleteNotification(notificationId);
    await loadNotifications(userId);
  }

  Future<void> markAllAsRead(String userId) async {
    await dataSource.markAllAsRead(userId);
    await loadNotifications(userId);
  }

  Future<void> addNotification({
    required String userId,
    required String title,
    String? body,
    String? taskId,
    String type = 'reminder',
  }) async {
    final notification = NotificationModel(
      id: const Uuid().v4(),
      userId: userId,
      taskId: taskId,
      notificationType: type,
      title: title,
      body: body,
      createdAt: DateTime.now(),
    );
    await dataSource.insertNotification(notification);
    await loadNotifications(userId);
  }
}
