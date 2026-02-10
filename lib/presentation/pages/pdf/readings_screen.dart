import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../providers/reading_notifier.dart';
import '../../providers/subject_notifier.dart';
import '../../../domain/entities/reading_entity.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/auth_notifier.dart';
import 'pdf_reader_screen.dart';

class ReadingsScreen extends ConsumerStatefulWidget {
  const ReadingsScreen({super.key});

  @override
  ConsumerState<ReadingsScreen> createState() => _ReadingsScreenState();
}

class _ReadingsScreenState extends ConsumerState<ReadingsScreen> {
  String? _selectedSubjectId;

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectNotifierProvider).subjects;
    final readingsState = ref.watch(readingNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lecturas')),
      body: Column(
        children: [
          // Subject Filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              key: ValueKey(_selectedSubjectId),
              initialValue: _selectedSubjectId,
              hint: const Text('Seleccionar Materia'),
              items: subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject.id,
                  child: Text(subject.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubjectId = value;
                });
                if (value != null) {
                  ref
                      .read(readingNotifierProvider.notifier)
                      .loadReadings(value);
                }
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),

          // Readings List
          Expanded(
            child: _selectedSubjectId == null
                ? const Center(
                    child: Text('Selecciona una materia para ver lecturas'),
                  )
                : readingsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : readingsState.readings.isEmpty
                ? const Center(child: Text('No hay lecturas disponibles'))
                : ListView.builder(
                    itemCount: readingsState.readings.length,
                    itemBuilder: (context, index) {
                      final reading = readingsState.readings[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                        ),
                        title: Text(reading.title),
                        subtitle: LinearProgressIndicator(
                          value: reading.readingProgress,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            reading.isCompleted ? Colors.green : Colors.blue,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            _confirmDelete(context, reading);
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PDFReaderScreen(reading: reading),
                            ),
                          ).then((_) {
                            // Refresh on return
                            if (_selectedSubjectId != null) {
                              ref
                                  .read(readingNotifierProvider.notifier)
                                  .loadReadings(_selectedSubjectId!);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _selectedSubjectId != null
          ? FloatingActionButton(
              onPressed: _pickPDF,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final fileSize = await file.length();

      // Get persistent directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileNameUnique = '${const Uuid().v4()}_$fileName';
      final savedFile = await file.copy('${appDir.path}/$fileNameUnique');

      final user = ref.read(authNotifierProvider).user;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Usuario no identificado')),
          );
        }
        return;
      }

      // Create Reading Entity
      final newReading = Reading(
        id: const Uuid().v4(),
        subjectId: _selectedSubjectId!,
        userId: user.userId,
        title: fileName,
        filePath: savedFile.path,
        fileSize: fileSize,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add to database
      await ref.read(readingNotifierProvider.notifier).add(newReading);
    }
  }

  void _confirmDelete(BuildContext context, Reading reading) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Lectura'),
        content: Text('¿Deseas eliminar "${reading.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(readingNotifierProvider.notifier)
                  .delete(reading.id, reading.subjectId);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
