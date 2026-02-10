import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/date_utils.dart' as date_utils;
import '../widgets/molecules/empty_state.dart';
import '../widgets/molecules/offline_banner.dart';
import '../providers/auth_notifier.dart';
import '../providers/subject_notifier.dart';
import '../providers/task_notifier.dart';
import '../providers/sprint6_providers.dart';
import '../../domain/entities/task_entity.dart';
import '../widgets/search_delegate.dart';
import 'package:showcaseview/showcaseview.dart';
import '../providers/tutorial_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey _summaryKey = GlobalKey();
  final GlobalKey _recentTaskKey = GlobalKey();

  int _pendingCount = 0;
  int _completedCount = 0;
  double _completionRate = 0.0;
  int _overdueCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _checkTutorial();
    });
  }

  void _checkTutorial() {
    final tutorialState = ref.read(tutorialNotifierProvider);
    if (!tutorialState.hasSeenHomeTutorial) {
      // ignore: deprecated_member_use
      ShowCaseWidget.of(context).startShowCase([_summaryKey, _recentTaskKey]);
      ref.read(tutorialNotifierProvider.notifier).completeHomeTutorial();
    }
  }

  Future<void> _loadData() async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    // Load subjects and tasks
    ref.read(subjectNotifierProvider.notifier).loadSubjects(user.userId);
    ref.read(taskNotifierProvider.notifier).loadTasks(user.userId);

    // Load statistics
    final stats = ref.read(statisticsServiceProvider);
    final pending = await stats.getPendingTasksCount(user.userId);
    final completed = await stats.getCompletedTasksCount(user.userId);
    final rate = await stats.getCompletionRate(user.userId);
    final overdue = await stats.getOverdueTasksCount(user.userId);

    // Load unread notifications
    ref
        .read(notificationNotifierProvider.notifier)
        .loadNotifications(user.userId);

    if (mounted) {
      setState(() {
        _pendingCount = pending;
        _completedCount = completed;
        _completionRate = rate;
        _overdueCount = overdue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final theme = Theme.of(context);
    final subjectState = ref.watch(subjectNotifierProvider);
    final taskState = ref.watch(taskNotifierProvider);
    final notifState = ref.watch(notificationNotifierProvider);

    // Get upcoming tasks (next 7 days, not completed)
    final upcomingTasks =
        taskState.tasks.where((t) {
          if (t.status == 'completed') return false;
          if (t.dueDate == null) return false;
          final diff = t.dueDate!.difference(DateTime.now()).inDays;
          return diff >= 0 && diff <= 7;
        }).toList()..sort((a, b) {
          final aDate = a.dueDate ?? DateTime(9999);
          final bDate = b.dueDate ?? DateTime(9999);
          return aDate.compareTo(bDate);
        });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Academic Task Manager'),
            Text(
              date_utils.DateUtilsHelper.formatDate(today),
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar',
            onPressed: () {
              showSearch(context: context, delegate: CustomSearchDelegate(ref));
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronización',
            onPressed: () => context.push('/sync-history'),
          ),
          // Notifications with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => context.push('/notifications'),
              ),
              if (notifState.unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${notifState.unreadCount > 9 ? "9+" : notifState.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Overview Cards ──
                    _buildSectionHeader(context, 'Resumen'),
                    const SizedBox(height: 12),
                    Showcase(
                      key: _summaryKey,
                      title: 'Resumen Académico',
                      description:
                          'Aquí verás un resumen rápido de tus pendientes y progreso.',
                      child: _buildOverviewCards(context),
                    ),
                    const SizedBox(height: 24),

                    // ── Upcoming Tasks ──
                    Showcase(
                      key: _recentTaskKey,
                      title: 'Tareas Recientes',
                      description: 'Tus próximas tareas aparecerán aquí.',
                      child: _buildSectionHeader(
                        context,
                        'Próximas entregas',
                        action: 'Ver todas',
                        onAction: () => context.go('/tasks'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (upcomingTasks.isEmpty)
                      const EmptyState(
                        message: '¡Sin tareas pendientes esta semana!',
                        icon: Icons.check_circle_outline,
                      )
                    else
                      ...upcomingTasks
                          .take(5)
                          .map((task) => _UpcomingTaskCard(task: task)),
                    const SizedBox(height: 24),

                    // ── Active Subjects ──
                    _buildSectionHeader(
                      context,
                      'Materias activas',
                      action: 'Ver todas',
                      onAction: () => context.go('/subjects'),
                    ),
                    const SizedBox(height: 12),
                    if (subjectState.subjects.isEmpty)
                      const SizedBox(
                        height: 80,
                        child: Center(
                          child: Text('No hay materias registradas'),
                        ),
                      )
                    else
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: subjectState.subjects.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final subject = subjectState.subjects[index];
                            final color = Color(
                              int.parse(
                                '0xFF${subject.colorHex.replaceAll('#', '')}',
                              ),
                            );
                            return InkWell(
                              onTap: () =>
                                  context.push('/subjects/${subject.id}'),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 140,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.book, color: color, size: 24),
                                    const SizedBox(height: 8),
                                    Text(
                                      subject.name,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 24),

                    // ── Quick Actions ──
                    _buildSectionHeader(context, 'Acciones rápidas'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.grade,
                            label: 'Calificaciones',
                            color: Colors.purple,
                            onTap: () => context.push('/grades'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.bar_chart,
                            label: 'Estadísticas',
                            color: Colors.teal,
                            onTap: () {
                              _showStatsDialog(context);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.book_online,
                            label: 'Lecturas',
                            color: Colors.orange,
                            onTap: () => context.push('/readings'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.calendar_month,
                            label: 'Calendario',
                            color: Colors.blue,
                            onTap: () => context.push('/calendar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    String? action,
    VoidCallback? onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (action != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(action)),
      ],
    );
  }

  Widget _buildOverviewCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            'Pendientes',
            '$_pendingCount',
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            'Completadas',
            '$_completedCount',
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            'Vencidas',
            '$_overdueCount',
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Estadísticas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatRow(
              icon: Icons.pending_actions,
              label: 'Tareas pendientes',
              value: '$_pendingCount',
              color: Colors.orange,
            ),
            _StatRow(
              icon: Icons.check_circle,
              label: 'Tareas completadas',
              value: '$_completedCount',
              color: Colors.green,
            ),
            _StatRow(
              icon: Icons.warning,
              label: 'Tareas vencidas',
              value: '$_overdueCount',
              color: Colors.red,
            ),
            const Divider(),
            _StatRow(
              icon: Icons.pie_chart,
              label: 'Tasa de completado',
              value: '${_completionRate.toStringAsFixed(1)}%',
              color: Colors.blue,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

// ─── Upcoming Task Card ─────────────────────────────────

class _UpcomingTaskCard extends StatelessWidget {
  final Task task;

  const _UpcomingTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final daysLeft = task.dueDate != null
        ? task.dueDate!.difference(DateTime.now()).inDays
        : 999;

    Color urgencyColor;
    String urgencyLabel;
    if (daysLeft <= 0) {
      urgencyColor = Colors.red;
      urgencyLabel = '¡Hoy!';
    } else if (daysLeft == 1) {
      urgencyColor = Colors.orange;
      urgencyLabel = 'Mañana';
    } else {
      urgencyColor = Colors.blue;
      urgencyLabel = 'En $daysLeft días';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: urgencyColor.withValues(alpha: 0.15),
          child: Icon(Icons.assignment, color: urgencyColor, size: 20),
        ),
        title: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: urgencyColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            urgencyLabel,
            style: TextStyle(
              color: urgencyColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        dense: true,
      ),
    );
  }
}

// ─── Stat Row ───────────────────────────────────────────

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Action ───────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
