import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

/// Service for managing local notifications (reminders, alerts)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the notification system
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const channel = AndroidNotificationChannel(
      'academic_tasks',
      'Tareas Académicas',
      description: 'Recordatorios de tareas y entregas',
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  /// Show an immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'academic_tasks',
      'Tareas Académicas',
      channelDescription: 'Recordatorios de tareas y entregas',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  /// Schedule a notification at a specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // For scheduled notifications we use zonedSchedule which requires TZDateTime
    // For simplicity, using show with a delayed Future as a fallback
    final delay = scheduledDate.difference(DateTime.now());
    if (delay.isNegative) return;

    Future.delayed(delay, () {
      showNotification(id: id, title: title, body: body, payload: payload);
    });
  }

  /// Schedule task reminders: 24h before, 1h before, at due time
  Future<void> scheduleTaskReminders({
    required String taskId,
    required String taskTitle,
    required DateTime dueDate,
  }) async {
    final baseId = taskId.hashCode.abs();

    // 24 hours before
    final dayBefore = dueDate.subtract(const Duration(hours: 24));
    if (dayBefore.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: baseId,
        title: '📚 Entrega mañana',
        body: 'La tarea "$taskTitle" vence mañana',
        scheduledDate: dayBefore,
        payload: 'task:$taskId',
      );
    }

    // 1 hour before
    final hourBefore = dueDate.subtract(const Duration(hours: 1));
    if (hourBefore.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: baseId + 1,
        title: '⏰ Entrega en 1 hora',
        body: 'La tarea "$taskTitle" vence en 1 hora',
        scheduledDate: hourBefore,
        payload: 'task:$taskId',
      );
    }

    // At due time
    if (dueDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: baseId + 2,
        title: '🚨 ¡Entrega ahora!',
        body: 'La tarea "$taskTitle" vence en este momento',
        scheduledDate: dueDate,
        payload: 'task:$taskId',
      );
    }
  }

  /// Cancel a notification by ID
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id: id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap — can be extended to navigate to specific screens
    debugPrint('Notification tapped: ${response.payload}');
  }
}
