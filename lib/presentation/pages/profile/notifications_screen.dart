import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/sprint6_providers.dart';
import '../../providers/auth_notifier.dart';
import '../../../domain/entities/notification_entity.dart' as app;

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNotifications());
  }

  void _loadNotifications() {
    final user = ref.read(authNotifierProvider).user;
    if (user != null) {
      ref
          .read(notificationNotifierProvider.notifier)
          .loadNotifications(user.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationNotifierProvider);
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          if (state.unreadCount > 0)
            TextButton.icon(
              onPressed: () {
                if (user != null) {
                  ref
                      .read(notificationNotifierProvider.notifier)
                      .markAllAsRead(user.userId);
                }
              },
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Leer todas'),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none,
                          size: 64, color: theme.disabledColor),
                      const SizedBox(height: 16),
                      Text(
                        'Sin notificaciones',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Las notificaciones de tareas aparecerán aquí',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => _loadNotifications(),
                  child: _buildGroupedList(state.notifications, theme),
                ),
    );
  }

  Widget _buildGroupedList(
      List<app.Notification> notifications, ThemeData theme) {
    final grouped = _groupByDate(notifications);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final group = grouped[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                group.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Notification tiles
            ...group.notifications.map(
              (n) => _NotificationTile(
                notification: n,
                onTap: () {
                  final user = ref.read(authNotifierProvider).user;
                  if (user != null && !n.isRead) {
                    ref
                        .read(notificationNotifierProvider.notifier)
                        .markAsRead(n.id, user.userId);
                  }
                },
                onDismissed: () {
                  final user = ref.read(authNotifierProvider).user;
                  if (user != null) {
                    ref
                        .read(notificationNotifierProvider.notifier)
                        .deleteNotification(n.id, user.userId);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  List<_DateGroup> _groupByDate(List<app.Notification> notifications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final todayList = <app.Notification>[];
    final yesterdayList = <app.Notification>[];
    final weekList = <app.Notification>[];
    final olderList = <app.Notification>[];

    for (final n in notifications) {
      final d = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      if (d == today) {
        todayList.add(n);
      } else if (d == yesterday) {
        yesterdayList.add(n);
      } else if (d.isAfter(weekAgo)) {
        weekList.add(n);
      } else {
        olderList.add(n);
      }
    }

    final groups = <_DateGroup>[];
    if (todayList.isNotEmpty) {
      groups.add(_DateGroup('Hoy', todayList));
    }
    if (yesterdayList.isNotEmpty) {
      groups.add(_DateGroup('Ayer', yesterdayList));
    }
    if (weekList.isNotEmpty) {
      groups.add(_DateGroup('Esta semana', weekList));
    }
    if (olderList.isNotEmpty) {
      groups.add(_DateGroup('Anteriores', olderList));
    }
    return groups;
  }
}

class _DateGroup {
  final String label;
  final List<app.Notification> notifications;
  _DateGroup(this.label, this.notifications);
}

class _NotificationTile extends StatelessWidget {
  final app.Notification notification;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismissed,
  });

  IconData _iconForType(String type) {
    switch (type) {
      case 'task':
        return Icons.task_alt;
      case 'reminder':
        return Icons.alarm;
      case 'sync':
        return Icons.sync;
      case 'grade':
        return Icons.grade;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'task':
        return Colors.blue;
      case 'reminder':
        return Colors.orange;
      case 'sync':
        return Colors.green;
      case 'grade':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorForType(notification.notificationType);
    final timeStr = DateFormat('HH:mm').format(notification.createdAt);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDismissed(),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(
            _iconForType(notification.notificationType),
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.w600,
          ),
        ),
        subtitle: notification.body != null
            ? Text(
                notification.body!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              )
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(timeStr, style: theme.textTheme.bodySmall),
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
