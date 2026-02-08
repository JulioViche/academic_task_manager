import 'package:flutter/material.dart';

enum Priority { low, medium, high }

class PriorityBadge extends StatelessWidget {
  final Priority priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (priority) {
      case Priority.low:
        color = Colors.green;
        text = 'Low';
        break;
      case Priority.medium:
        color = Colors.orange;
        text = 'Medium';
        break;
      case Priority.high:
        color = Colors.red;
        text = 'High';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
