import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/reading_entity.dart';
import '../../providers/reading_notifier.dart';

class PDFReaderScreen extends ConsumerStatefulWidget {
  final Reading reading;

  const PDFReaderScreen({super.key, required this.reading});

  @override
  ConsumerState<PDFReaderScreen> createState() => _PDFReaderScreenState();
}

class _PDFReaderScreenState extends ConsumerState<PDFReaderScreen> {
  late PdfViewerController _pdfViewerController;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    // Restore progress
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.reading.currentPage > 0) {
        _pdfViewerController.jumpToPage(widget.reading.currentPage);
      }
    });
  }

  void _saveProgress() {
    final currentPage = _pdfViewerController.pageNumber;
    final totalPages = _pdfViewerController.pageCount;
    final progress = totalPages > 0 ? currentPage / totalPages : 0.0;
    final isCompleted = progress >= 0.95; // 95% threshold

    ref
        .read(readingNotifierProvider.notifier)
        .updateReadingProgress(
          widget.reading.id,
          widget.reading.subjectId,
          currentPage,
          progress,
          isCompleted,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reading.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              _saveProgress();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progreso guardado')),
              );
            },
          ),
        ],
      ),
      body: widget.reading.filePath != null
          ? SfPdfViewer.file(
              File(widget.reading.filePath!),
              controller: _pdfViewerController,
              key: _pdfViewerKey,
              onPageChanged: (PdfPageChangedDetails details) {
                // Auto-save progress every 5 pages or so? Maybe just on dispose or manual save is better for perforamnce
              },
            )
          : const Center(child: Text('Archivo no encontrado')),
    );
  }

  @override
  void dispose() {
    _saveProgress(); // Auto-save on exit
    super.dispose();
  }
}
