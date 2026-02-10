import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/sprint6_providers.dart';

class AddGradeDialog extends ConsumerStatefulWidget {
  final String subjectId;
  final String userId;
  final VoidCallback onGradeAdded;

  const AddGradeDialog({
    super.key,
    required this.subjectId,
    required this.userId,
    required this.onGradeAdded,
  });

  @override
  ConsumerState<AddGradeDialog> createState() => _AddGradeDialogState();
}

class _AddGradeDialogState extends ConsumerState<AddGradeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _scoreController = TextEditingController();
  final _maxScoreController = TextEditingController(text: '10');
  final _weightController = TextEditingController(text: '1.0');
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _gradeType = 'exam';
  bool _isSubmitting = false;

  final _gradeTypes = {
    'exam': 'Examen',
    'quiz': 'Quiz',
    'homework': 'Tarea',
    'project': 'Proyecto',
    'participation': 'Participación',
    'other': 'Otro',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _scoreController.dispose();
    _maxScoreController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(gradeNotifierProvider.notifier).addGrade(
            subjectId: widget.subjectId,
            userId: widget.userId,
            gradeType: _gradeType,
            gradeName: _nameController.text.trim(),
            score: double.parse(_scoreController.text),
            maxScore: double.parse(_maxScoreController.text),
            weight: double.tryParse(_weightController.text) ?? 1.0,
            date: _selectedDate,
            notes: _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
          );

      widget.onGradeAdded();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Nueva Calificación'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grade name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la evaluación',
                  hintText: 'Ej: Parcial 1, Quiz 3...',
                  prefixIcon: Icon(Icons.edit),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),

              // Grade type dropdown
              DropdownButtonFormField<String>(
                value: _gradeType,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _gradeTypes.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _gradeType = v ?? 'exam'),
              ),
              const SizedBox(height: 12),

              // Score and max score row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _scoreController,
                      decoration: const InputDecoration(
                        labelText: 'Nota',
                        hintText: '8.5',
                        prefixIcon: Icon(Icons.star),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        final score = double.tryParse(v);
                        if (score == null || score < 0) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxScoreController,
                      decoration: const InputDecoration(
                        labelText: 'Máxima',
                        hintText: '10',
                        prefixIcon: Icon(Icons.star_border),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        final max = double.tryParse(v);
                        if (max == null || max <= 0) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Weight
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Peso (opcional)',
                  hintText: '1.0',
                  prefixIcon: Icon(Icons.balance),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),

              // Date picker
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  hintText: 'Comentarios adicionales...',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
