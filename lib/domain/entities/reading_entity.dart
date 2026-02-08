import 'package:equatable/equatable.dart';

class Reading extends Equatable {
  final String id;
  final String subjectId;
  final String userId;
  final String title;
  final String? description;
  final String? filePath;
  final String? cloudUrl;
  final int? fileSize;
  final int? totalPages;
  final int currentPage;
  final double readingProgress;
  final bool isCompleted;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastRead;
  final String syncStatus;
  final String? serverId;

  const Reading({
    required this.id,
    required this.subjectId,
    required this.userId,
    required this.title,
    this.description,
    this.filePath,
    this.cloudUrl,
    this.fileSize,
    this.totalPages,
    this.currentPage = 0,
    this.readingProgress = 0.0,
    this.isCompleted = false,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.lastRead,
    this.syncStatus = 'synced',
    this.serverId,
  });

  @override
  List<Object?> get props => [
    id,
    subjectId,
    userId,
    title,
    description,
    filePath,
    cloudUrl,
    fileSize,
    totalPages,
    currentPage,
    readingProgress,
    isCompleted,
    notes,
    createdAt,
    updatedAt,
    lastRead,
    syncStatus,
    serverId,
  ];
}
