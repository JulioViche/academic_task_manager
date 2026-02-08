import 'package:equatable/equatable.dart';

class Attachment extends Equatable {
  final String id;
  final String? taskId;
  final String? subjectId;
  final String userId;
  final String fileName;
  final String fileType;
  final String filePath;
  final int? fileSize;
  final String? cloudUrl;
  final String? mimeType;
  final String? thumbnailPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final int uploadProgress;
  final String? serverId;

  const Attachment({
    required this.id,
    this.taskId,
    this.subjectId,
    required this.userId,
    required this.fileName,
    required this.fileType,
    required this.filePath,
    this.fileSize,
    this.cloudUrl,
    this.mimeType,
    this.thumbnailPath,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'synced',
    this.uploadProgress = 0,
    this.serverId,
  });

  @override
  List<Object?> get props => [
    id,
    taskId,
    subjectId,
    userId,
    fileName,
    fileType,
    filePath,
    fileSize,
    cloudUrl,
    mimeType,
    thumbnailPath,
    createdAt,
    updatedAt,
    syncStatus,
    uploadProgress,
    serverId,
  ];
}
