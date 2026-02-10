import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/subject_entity.dart';
import '../providers/subject_notifier.dart';
import '../providers/auth_notifier.dart';
import '../widgets/molecules/empty_state.dart';

class SubjectsScreen extends ConsumerStatefulWidget {
  const SubjectsScreen({super.key});

  @override
  ConsumerState<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends ConsumerState<SubjectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSubjects();
    });
  }

  void _loadSubjects() {
    final authState = ref.read(authNotifierProvider);
    if (authState.user != null) {
      ref
          .read(subjectNotifierProvider.notifier)
          .loadSubjects(authState.user!.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth changes to reload data if user changes or logs in
    ref.listen(authNotifierProvider, (previous, next) {
      if (previous?.user?.userId != next.user?.userId && next.user != null) {
        _loadSubjects();
      }
    });

    final subjectState = ref.watch(subjectNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materias'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadSubjects),
        ],
      ),
      body: _buildBody(context, subjectState),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSubjectDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SubjectState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(state.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSubjects,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.subjects.isEmpty) {
      return const EmptyState(
        icon: Icons.school_outlined,
        message: 'No tienes materias aún',
        subMessage: 'Presiona + para agregar tu primera materia',
      );
    }

    return RefreshIndicator(
    onRefresh: () async => _loadSubjects(),
    child: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.subjects.length,
      itemBuilder: (context, index) {
        final subject = state.subjects[index];
        return _SubjectCard(
          subject: subject,
          onTap: () => context.push('/subjects/${subject.id}'),
          onEdit: () => _showEditSubjectDialog(context, subject),
          onDelete: () => _confirmDeleteSubject(context, subject),
        );
      },
    ),
  );
  }

  void _showAddSubjectDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SubjectFormSheet(
        onSave: (name, code, color, teacher) async {
          final authState = ref.read(authNotifierProvider);
          if (authState.user == null) return;

          final subject = Subject(
            id: const Uuid().v4(),
            userId: authState.user!.userId,
            name: name,
            code: code,
            colorHex: color,
            teacherName: teacher,
          );

          final success = await ref
              .read(subjectNotifierProvider.notifier)
              .addSubject(subject);
          if (!context.mounted) return;
          if (success) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Materia agregada correctamente')),
            );
          }
        },
      ),
    );
  }

  void _showEditSubjectDialog(BuildContext context, Subject subject) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SubjectFormSheet(
        subject: subject,
        onSave: (name, code, color, teacher) async {
          final updatedSubject = Subject(
            id: subject.id,
            userId: subject.userId,
            name: name,
            code: code,
            colorHex: color,
            teacherName: teacher,
          );

          final success = await ref
              .read(subjectNotifierProvider.notifier)
              .updateSubject(updatedSubject);
          if (!context.mounted) return;
          if (success) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Materia actualizada')),
            );
          }
        },
      ),
    );
  }

  void _confirmDeleteSubject(BuildContext context, Subject subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Materia'),
        content: Text(
          '¿Estás seguro de eliminar "${subject.name}"?\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(subjectNotifierProvider.notifier)
                  .deleteSubject(subject.id);
              if (!context.mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Materia eliminada')),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SubjectCard({
    required this.subject,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(subject.colorHex);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: color.withAlpha((255 * 0.2).round()),
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withAlpha((255 * 0.2).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.school, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (subject.code != null && subject.code!.isNotEmpty)
                        Text(
                          subject.code!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      if (subject.teacherName.isNotEmpty)
                        Text(
                          subject.teacherName,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Editar')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Eliminar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubjectFormSheet extends StatefulWidget {
  final Subject? subject;
  final Function(String name, String? code, String color, String teacher)
  onSave;

  const SubjectFormSheet({super.key, this.subject, required this.onSave});

  @override
  State<SubjectFormSheet> createState() => _SubjectFormSheetState();
}

class _SubjectFormSheetState extends State<SubjectFormSheet> {
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _teacherController;
  String _selectedColor = '#2196F3';
  final _formKey = GlobalKey<FormState>();

  final List<String> _colors = [
    '#2196F3',
    '#4CAF50',
    '#FF9800',
    '#F44336',
    '#9C27B0',
    '#00BCD4',
    '#795548',
    '#607D8B',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject?.name ?? '');
    _codeController = TextEditingController(text: widget.subject?.code ?? '');
    _teacherController = TextEditingController(
      text: widget.subject?.teacherName ?? '',
    );
    _selectedColor = widget.subject?.colorHex ?? '#2196F3';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _teacherController.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.subject == null ? 'Nueva Materia' : 'Editar Materia',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Materia *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Código / NRC',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _teacherController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Docente',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text('Color', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _colors.map((color) {
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _parseColor(color),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _parseColor(color),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSave(
                      _nameController.text.trim(),
                      _codeController.text.trim().isEmpty
                          ? null
                          : _codeController.text.trim(),
                      _selectedColor,
                      _teacherController.text.trim(),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    widget.subject == null
                        ? 'Agregar Materia'
                        : 'Guardar Cambios',
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
