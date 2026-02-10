import 'package:flutter/material.dart';
import '../../../../domain/entities/subject_entity.dart';
import '../atoms/sync_status_badge.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;

  const SubjectCard({super.key, required this.subject, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Parse hex color string to Color, defaulting to blue if invalid
    Color subjectColor = Colors.blue;
    try {
      // Access colorHex safely
      final hex = subject.colorHex;
      if (hex.isNotEmpty) {
        subjectColor = Color(int.parse(hex.replaceFirst('#', '0xFF')));
      }
    } catch (e) {
      // Ignore parsing error, keep default
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: subjectColor, width: 4)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      subject.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (subject.syncStatus != 'synced')
                    SyncStatusBadge(syncStatus: subject.syncStatus),
                ],
              ),
              const SizedBox(height: 4),
              if (subject.code?.isNotEmpty ?? false)
                Text(
                  subject.code!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              if (subject.teacherName.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        subject.teacherName,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
