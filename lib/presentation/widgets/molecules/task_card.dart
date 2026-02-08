import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/task_entity.dart';
import '../atoms/priority_badge.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final ValueChanged<bool?>? onCheckboxChanged;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == 'completed';
    final isOverdue =
        !isCompleted &&
        task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now());

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Checkbox(
                value: isCompleted,
                onChanged: onCheckboxChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.dueDate != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: isOverdue ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(task.dueDate!),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: isOverdue ? Colors.red : Colors.grey,
                                  fontWeight: isOverdue
                                      ? FontWeight.bold
                                      : null,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Map string priority to enum
              if (!isCompleted)
                PriorityBadge(priority: _getPriorityFromString(task.priority)),
            ],
          ),
        ),
      ),
    );
  }

  Priority _getPriorityFromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Priority.high;
      case 'medium':
        return Priority.medium;
      default:
        return Priority.low;
    }
  }
}
