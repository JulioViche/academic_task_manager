import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/subject_entity.dart';
import '../../../domain/entities/task_entity.dart';
import '../../providers/subject_notifier.dart';
import '../../providers/task_notifier.dart';
import '../../providers/auth_notifier.dart';
import '../../widgets/molecules/empty_state.dart';
import '../tasks/task_detail_screen.dart';

class SubjectDetailScreen extends ConsumerStatefulWidget {
  final String subjectId;

  const SubjectDetailScreen({super.key, required this.subjectId});

  @override
  ConsumerState<SubjectDetailScreen> createState() =>
      _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends ConsumerState<SubjectDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final subjectState = ref.watch(subjectNotifierProvider);
    final taskState = ref.watch(taskNotifierProvider);

    Subject subject;
    try {
      subject = subjectState.subjects.firstWhere(
        (s) => s.id == widget.subjectId,
      );
    } catch (_) {
      subject = const Subject(
        id: '',
        userId: '',
        name: 'Materia no encontrada',
        colorHex: '#808080',
        teacherName: '',
      );
    }

    if (subject.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalles')),
        body: const Center(child: Text('Materia no encontrada')),
      );
    }

    final tasks = taskState.tasks
        .where((t) => t.subjectId == widget.subjectId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.name),
        backgroundColor: _parseColor(subject.colorHex),
        foregroundColor: Colors.white,
      ),
      body: _buildTaskList(tasks, taskState.isLoading),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(subject.id),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.blue;
    }
  }

  Widget _buildTaskList(List<Task> tasks, bool isLoading) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tasks.isEmpty) {
      return const EmptyState(
        icon: Icons.assignment_outlined,
        message: 'No hay tareas para esta materia',
        subMessage: 'Presiona + para agregar una tarea',
      );
    }

    // Sort: Pending first, then by date
    final sortedTasks = List<Task>.from(tasks)
      ..sort((a, b) {
        if (a.status == 'completed' && b.status != 'completed') return 1;
        if (a.status != 'completed' && b.status == 'completed') return -1;
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedTasks.length,
      itemBuilder: (context, index) {
        final task = sortedTasks[index];
        return _TaskCard(
          task: task,
          onComplete: () => _completeTask(task),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: task),
            ),
          ),
        );
      },
    );
  }

  void _completeTask(Task task) async {
    await ref.read(taskNotifierProvider.notifier).completeTask(task.id);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('¡Tarea completada!')));
  }

  void _showAddTaskDialog(String subjectId) {
    showDialog(
      context: context,
      builder: (context) => _SimpleTaskDialog(
        subjectId: subjectId,
        onSave: (title, dueDate) async {
          final authState = ref.read(authNotifierProvider);
          if (authState.user == null) return;

          final now = DateTime.now();
          final task = Task(
            id: const Uuid().v4(),
            subjectId: subjectId,
            userId: authState.user!.userId,
            title: title,
            description: null,
            priority: 'medium',
            dueDate: dueDate,
            createdAt: now,
            updatedAt: now,
            status: 'pending',
          );

          await ref.read(taskNotifierProvider.notifier).addTask(task);
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Tarea agregada')));
          }
        },
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onComplete;
  final VoidCallback onTap;

  const _TaskCard({
    required this.task,
    required this.onComplete,
    required this.onTap,
  });

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == 'completed';
    final isOverdue =
        task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        !isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: isCompleted,
                onChanged: isCompleted ? null : (_) => onComplete(),
                activeColor: Colors.green,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: isCompleted ? Colors.grey : null,
                      ),
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty)
                      Text(
                        task.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(
                              task.priority,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            task.priority.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getPriorityColor(task.priority),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (task.dueDate != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: isOverdue ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue ? Colors.red : Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleTaskDialog extends StatefulWidget {
  final String subjectId;
  final Function(String, DateTime?) onSave;

  const _SimpleTaskDialog({required this.subjectId, required this.onSave});

  @override
  State<_SimpleTaskDialog> createState() => _SimpleTaskDialogState();
}

class _SimpleTaskDialogState extends State<_SimpleTaskDialog> {
  final _titleController = TextEditingController();
  DateTime? _dueDate;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva Tarea Rápida'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Título'),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          ListTile(
            title: Text(
              _dueDate == null
                  ? 'Fecha de entrega (Opcional)'
                  : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) setState(() => _dueDate = date);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              widget.onSave(_titleController.text.trim(), _dueDate);
              Navigator.pop(context);
            }
          },
          child: const Text('Crear'),
        ),
      ],
    );
  }
}
