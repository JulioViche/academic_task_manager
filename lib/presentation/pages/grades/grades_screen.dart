import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/sprint6_providers.dart';
import '../../providers/subject_notifier.dart';
import '../../providers/auth_notifier.dart';
import '../../../domain/entities/grade_entity.dart';
import 'add_grade_dialog.dart';

class GradesScreen extends ConsumerStatefulWidget {
  const GradesScreen({super.key});

  @override
  ConsumerState<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends ConsumerState<GradesScreen> {
  String? _selectedSubjectId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSubjects();
    });
  }

  void _loadSubjects() {
    final user = ref.read(authNotifierProvider).user;
    if (user != null) {
      ref.read(subjectNotifierProvider.notifier).loadSubjects(user.userId);
    }
  }

  void _loadGrades(String subjectId) {
    ref.read(gradeNotifierProvider.notifier).loadGradesBySubject(subjectId);
  }

  Color _gradeColor(double average) {
    if (average >= 7) return Colors.green;
    if (average >= 5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final subjectState = ref.watch(subjectNotifierProvider);
    final gradeState = ref.watch(gradeNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calificaciones'),
        elevation: 0,
      ),
      body: subjectState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : subjectState.subjects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined,
                          size: 64, color: theme.disabledColor),
                      const SizedBox(height: 16),
                      Text('No hay materias registradas',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Crea una materia para agregar calificaciones',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.disabledColor,
                          )),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: subjectState.subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjectState.subjects[index];
                    final isSelected = _selectedSubjectId == subject.id;
                    final average =
                        gradeState.averages[subject.id] ?? 0.0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          // Subject header
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedSubjectId = null;
                                } else {
                                  _selectedSubjectId = subject.id;
                                  _loadGrades(subject.id);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Color(int.parse(
                                              '0xFF${subject.colorHex.replaceAll('#', '')}'))
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.book,
                                      color: Color(int.parse(
                                          '0xFF${subject.colorHex.replaceAll('#', '')}')),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          subject.name,
                                          style:
                                              theme.textTheme.titleMedium
                                                  ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (subject.teacherName != null)
                                          Text(
                                            subject.teacherName!,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: theme.disabledColor,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Average badge
                                  if (average > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color:
                                            _gradeColor(average).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        average.toStringAsFixed(1),
                                        style: TextStyle(
                                          color: _gradeColor(average),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    isSelected
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Expandable grades list
                          if (isSelected) ...[
                            if (gradeState.isLoading)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            else if (gradeState.grades.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    Icon(Icons.grade_outlined,
                                        size: 40, color: theme.disabledColor),
                                    const SizedBox(height: 8),
                                    Text('Sin calificaciones',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: theme.disabledColor,
                                        )),
                                  ],
                                ),
                              )
                            else
                              ...gradeState.grades.map(
                                (grade) => _GradeTile(
                                  grade: grade,
                                  onDelete: () {
                                    ref
                                        .read(gradeNotifierProvider.notifier)
                                        .deleteGrade(grade.id, subject.id);
                                  },
                                ),
                              ),
                            // Add grade button
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextButton.icon(
                                onPressed: () => _showAddGradeDialog(subject.id),
                                icon: const Icon(Icons.add),
                                label: const Text('Agregar calificación'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: _selectedSubjectId != null
          ? FloatingActionButton(
              onPressed: () => _showAddGradeDialog(_selectedSubjectId!),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showAddGradeDialog(String subjectId) {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => AddGradeDialog(
        subjectId: subjectId,
        userId: user.userId,
        onGradeAdded: () {
          _loadGrades(subjectId);
        },
      ),
    );
  }
}

// ─── Grade Tile ─────────────────────────────────────────

class _GradeTile extends StatelessWidget {
  final Grade grade;
  final VoidCallback onDelete;

  const _GradeTile({required this.grade, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (grade.score / grade.maxScore * 100);
    final dateStr = DateFormat('dd/MM/yyyy').format(grade.date);

    Color scoreColor;
    if (percentage >= 70) {
      scoreColor = Colors.green;
    } else if (percentage >= 50) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: scoreColor.withValues(alpha: 0.15),
        child: Text(
          '${percentage.round()}',
          style: TextStyle(
            color: scoreColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
      title: Text(grade.gradeName),
      subtitle: Text(
        '${grade.score}/${grade.maxScore} • $dateStr',
        style: theme.textTheme.bodySmall,
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete_outline, color: theme.disabledColor, size: 20),
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Eliminar calificación'),
              content: Text('¿Eliminar "${grade.gradeName}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    onDelete();
                  },
                  child: const Text('Eliminar',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
      ),
      dense: true,
    );
  }
}
