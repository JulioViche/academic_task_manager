import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/reading_entity.dart';
import '../../providers/reading_notifier.dart';

class PDFReaderScreen extends ConsumerStatefulWidget {
  final Reading? reading;
  final String? filePath;
  final String? url;
  final String? title;

  const PDFReaderScreen({
    super.key,
    this.reading,
    this.filePath,
    this.url,
    this.title,
  });

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
      if (widget.reading != null && widget.reading!.currentPage > 0) {
        _pdfViewerController.jumpToPage(widget.reading!.currentPage);
      }
    });
  }

  void _saveProgress() {
    if (widget.reading == null) return;

    final currentPage = _pdfViewerController.pageNumber;
    final totalPages = _pdfViewerController.pageCount;
    final progress = totalPages > 0 ? currentPage / totalPages : 0.0;
    final isCompleted = progress >= 0.95; // 95% threshold

    ref
        .read(readingNotifierProvider.notifier)
        .updateReadingProgress(
          widget.reading!.id,
          widget.reading!.subjectId,
          currentPage,
          progress,
          isCompleted,
        );
  }

  @override
  Widget build(BuildContext context) {
    String displayTitle =
        widget.title ?? (widget.reading?.title ?? 'Documento PDF');
    String? path = widget.filePath ?? widget.reading?.filePath;
    String? netUrl = widget.url ?? widget.reading?.cloudUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text(displayTitle),
        actions: [
          if (widget.reading != null)
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
      body: path != null
          ? SfPdfViewer.file(
              File(path),
              controller: _pdfViewerController,
              key: _pdfViewerKey,
              onPageChanged: (PdfPageChangedDetails details) {
                // Auto-save disabled for non-reading items
              },
            )
          : (netUrl != null
                ? SfPdfViewer.network(
                    netUrl,
                    controller: _pdfViewerController,
                    key: _pdfViewerKey,
                  )
                : const Center(child: Text('Archivo no encontrado'))),
    );
  }

  @override
  void dispose() {
    _saveProgress(); // Auto-save on exit
    super.dispose();
  }
}
