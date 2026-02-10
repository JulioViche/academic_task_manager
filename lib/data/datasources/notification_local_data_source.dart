import '../models/notification_model.dart';
import 'local/database_helper.dart';
import '../../core/error/exceptions.dart';

// ─── Interface ──────────────────────────────────────────

abstract class NotificationLocalDataSource {
  Future<List<NotificationModel>> getAllNotifications(String userId);
  Future<void> insertNotification(NotificationModel notification);
  Future<void> markAsRead(String notificationId);
  Future<void> deleteNotification(String notificationId);
  Future<int> getUnreadCount(String userId);
  Future<void> markAllAsRead(String userId);
}

// ─── Implementation ─────────────────────────────────────

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final DatabaseHelper databaseHelper;

  NotificationLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<NotificationModel>> getAllNotifications(String userId) async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query(
        'notifications',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
        limit: 100,
      );
      return maps.map((m) => NotificationModel.fromJson(m)).toList();
    } catch (e) {
      throw CacheException('Failed to get notifications: ${e.toString()}');
    }
  }

  @override
  Future<void> insertNotification(NotificationModel notification) async {
    try {
      final db = await databaseHelper.database;
      await db.insert('notifications', notification.toJson());
    } catch (e) {
      throw CacheException('Failed to insert notification: ${e.toString()}');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final db = await databaseHelper.database;
      await db.update(
        'notifications',
        {'is_read': 1},
        where: 'notification_id = ?',
        whereArgs: [notificationId],
      );
    } catch (e) {
      throw CacheException('Failed to mark as read: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        'notifications',
        where: 'notification_id = ?',
        whereArgs: [notificationId],
      );
    } catch (e) {
      throw CacheException('Failed to delete notification: ${e.toString()}');
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    try {
      final db = await databaseHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND is_read = 0',
        [userId],
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      throw CacheException('Failed to get unread count: ${e.toString()}');
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      final db = await databaseHelper.database;
      await db.update(
        'notifications',
        {'is_read': 1},
        where: 'user_id = ? AND is_read = 0',
        whereArgs: [userId],
      );
    } catch (e) {
      throw CacheException('Failed to mark all as read: ${e.toString()}');
    }
  }
}
