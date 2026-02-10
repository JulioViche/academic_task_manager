import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Service for managing local notifications (reminders, alerts)
/// Uses zonedSchedule for persistent notifications that survive app closure
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the notification system and timezone data
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz_data.initializeTimeZones();

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

    // Request notification permissions on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Request exact alarm permission for scheduled notifications
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

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
  /// Uses zonedSchedule so it persists even if the app is closed
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // Don't schedule in the past
    if (scheduledDate.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'academic_tasks',
      'Tareas Académicas',
      channelDescription: 'Recordatorios de tareas y entregas',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(android: androidDetails);

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzScheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Schedule task reminders: 24h before, 1h before, at due time
  /// These persist even if the app is closed
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

  /// Cancel all task reminders for a given task
  Future<void> cancelTaskReminders(String taskId) async {
    final baseId = taskId.hashCode.abs();
    await _plugin.cancel(id: baseId);
    await _plugin.cancel(id: baseId + 1);
    await _plugin.cancel(id: baseId + 2);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  /// Get list of pending (scheduled) notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }
}
