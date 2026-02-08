import '../../domain/entities/attachment_entity.dart';

class AttachmentModel extends Attachment {
  const AttachmentModel({
    required super.id,
    super.taskId,
    super.subjectId,
    required super.userId,
    required super.fileName,
    required super.fileType,
    required super.filePath,
    super.fileSize,
    super.cloudUrl,
    super.mimeType,
    super.thumbnailPath,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    super.uploadProgress,
    super.serverId,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['attachment_id'],
      taskId: json['task_id'],
      subjectId: json['subject_id'],
      userId: json['user_id'],
      fileName: json['file_name'],
      fileType: json['file_type'],
      filePath: json['file_path'],
      fileSize: json['file_size'],
      cloudUrl: json['cloud_url'],
      mimeType: json['mime_type'],
      thumbnailPath: json['thumbnail_path'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updated_at']),
      syncStatus: json['sync_status'] ?? 'synced',
      uploadProgress: json['upload_progress'] ?? 0,
      serverId: json['server_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attachment_id': id,
      'task_id': taskId,
      'subject_id': subjectId,
      'user_id': userId,
      'file_name': fileName,
      'file_type': fileType,
      'file_path': filePath,
      'file_size': fileSize,
      'cloud_url': cloudUrl,
      'mime_type': mimeType,
      'thumbnail_path': thumbnailPath,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'sync_status': syncStatus,
      'upload_progress': uploadProgress,
      'server_id': serverId,
    };
  }

  factory AttachmentModel.fromEntity(Attachment attachment) {
    return AttachmentModel(
      id: attachment.id,
      taskId: attachment.taskId,
      subjectId: attachment.subjectId,
      userId: attachment.userId,
      fileName: attachment.fileName,
      fileType: attachment.fileType,
      filePath: attachment.filePath,
      fileSize: attachment.fileSize,
      cloudUrl: attachment.cloudUrl,
      mimeType: attachment.mimeType,
      thumbnailPath: attachment.thumbnailPath,
      createdAt: attachment.createdAt,
      updatedAt: attachment.updatedAt,
      syncStatus: attachment.syncStatus,
      uploadProgress: attachment.uploadProgress,
      serverId: attachment.serverId,
    );
  }
}
