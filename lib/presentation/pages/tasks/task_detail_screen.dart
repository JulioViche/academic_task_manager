import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/entities/attachment_entity.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/attachment_provider.dart';
import '../../pages/pdf/pdf_reader_screen.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final List<Attachment> _attachments = [];

  @override
  void initState() {
    super.initState();
    // Fetch existing attachments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(attachmentNotifierProvider.notifier)
          .getAttachments(
            taskId: widget.task.id,
            subjectId: widget.task.subjectId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(attachmentNotifierProvider, (previous, next) {
      if (next is AttachmentSuccess) {
        setState(() {
          _attachments.add(next.attachment);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Archivo subido correctamente')),
        );
      } else if (next is AttachmentsLoaded) {
        setState(() {
          _attachments.clear();
          _attachments.addAll(next.attachments);
        });
      } else if (next is AttachmentError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de Tarea'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit or show edit dialog
              // Currently handled in parent screen, maybe move here?
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildDescription(),
            const SizedBox(height: 24),
            _buildAttachmentsSection(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAttachmentOptions(context),
        icon: const Icon(Icons.attach_file),
        label: const Text('Adjuntar'),
      ),
    );
  }

  Widget _buildHeader() {
    final dateFormat = DateFormat('dd MMM yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.task.title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildPriorityBadge(widget.task.priority),
            const SizedBox(width: 12),
            if (widget.task.dueDate != null)
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(widget.task.dueDate!),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    switch (priority) {
      case 'urgent':
        color = Colors.red;
        break;
      case 'high':
        color = Colors.orange;
        break;
      case 'medium':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    if (widget.task.description == null || widget.task.description!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          widget.task.description!,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Adjuntos',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            // Optional: Add attachment count
          ],
        ),
        const SizedBox(height: 12),
        if (_attachments.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No hay archivos adjuntos',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _attachments.length,
            itemBuilder: (context, index) {
              final attachment = _attachments[index];
              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.insert_drive_file,
                    color: Colors.blue,
                  ),
                  title: Text(attachment.fileName),
                  subtitle: Text(
                    attachment.fileSize != null
                        ? '${(attachment.fileSize! / 1024).toStringAsFixed(1)} KB'
                        : 'Unknown size',
                  ),
                  onTap: () => _openAttachment(attachment),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () => _downloadAttachment(attachment),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar Foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Seleccionar Archivo (PDF/Doc)'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      _uploadFile(File(image.path));
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      _uploadFile(File(result.files.single.path!));
    }
  }

  Future<void> _uploadFile(File file) async {
    final userId = ref.read(authNotifierProvider).user?.userId;
    if (userId == null) return;

    // Show loading indicator
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Subiendo archivo...')));

    // Call provider
    await ref
        .read(attachmentNotifierProvider.notifier)
        .uploadFile(
          file: file,
          userId: userId,
          taskId: widget.task.id,
          subjectId: widget.task.subjectId,
        );
  }

  void _openAttachment(Attachment attachment) {
    if (attachment.fileType == 'pdf' ||
        attachment.fileName.toLowerCase().endsWith('.pdf')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFReaderScreen(
            filePath: attachment.filePath,
            url: attachment.cloudUrl,
            title: attachment.fileName,
          ),
        ),
      );
    } else if (['jpg', 'jpeg', 'png'].contains(attachment.fileType) ||
        attachment.fileName.toLowerCase().endsWith('.jpg') ||
        attachment.fileName.toLowerCase().endsWith('.png')) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: attachment.filePath.isNotEmpty
              ? Image.file(File(attachment.filePath))
              : (attachment.cloudUrl != null
                    ? Image.network(attachment.cloudUrl!)
                    : const Center(child: Text('No image source'))),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Formato no soportado para previsualización'),
        ),
      );
    }
  }

  Future<void> _downloadAttachment(Attachment attachment) async {
    if (attachment.cloudUrl != null) {
      final Uri url = Uri.parse(attachment.cloudUrl!);
      try {
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          throw 'Could not launch $url';
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se puede abrir el enlace de descarga'),
            ),
          );
        }
      }
    } else if (attachment.filePath.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archivo local en: ${attachment.filePath}')),
      );
    }
  }
}
