import '../../domain/entities/reading_entity.dart';

class ReadingModel extends Reading {
  const ReadingModel({
    required super.id,
    required super.subjectId,
    required super.userId,
    required super.title,
    super.description,
    super.filePath,
    super.cloudUrl,
    super.fileSize,
    super.totalPages,
    super.currentPage,
    super.readingProgress,
    super.isCompleted,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
    super.lastRead,
    super.syncStatus,
    super.serverId,
  });

  factory ReadingModel.fromJson(Map<String, dynamic> json) {
    return ReadingModel(
      id: json['reading_id'],
      subjectId: json['subject_id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      filePath: json['file_path'],
      cloudUrl: json['cloud_url'],
      fileSize: json['file_size'],
      totalPages: json['total_pages'],
      currentPage: json['current_page'] ?? 0,
      readingProgress: (json['reading_progress'] as num?)?.toDouble() ?? 0.0,
      isCompleted: (json['is_completed'] as int?) == 1,
      notes: json['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updated_at']),
      lastRead: json['last_read'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['last_read'])
          : null,
      syncStatus: json['sync_status'] ?? 'synced',
      serverId: json['server_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reading_id': id,
      'subject_id': subjectId,
      'user_id': userId,
      'title': title,
      'description': description,
      'file_path': filePath,
      'cloud_url': cloudUrl,
      'file_size': fileSize,
      'total_pages': totalPages,
      'current_page': currentPage,
      'reading_progress': readingProgress,
      'is_completed': isCompleted ? 1 : 0,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'last_read': lastRead?.millisecondsSinceEpoch,
      'sync_status': syncStatus,
      'server_id': serverId,
    };
  }

  factory ReadingModel.fromEntity(Reading reading) {
    return ReadingModel(
      id: reading.id,
      subjectId: reading.subjectId,
      userId: reading.userId,
      title: reading.title,
      description: reading.description,
      filePath: reading.filePath,
      cloudUrl: reading.cloudUrl,
      fileSize: reading.fileSize,
      totalPages: reading.totalPages,
      currentPage: reading.currentPage,
      readingProgress: reading.readingProgress,
      isCompleted: reading.isCompleted,
      notes: reading.notes,
      createdAt: reading.createdAt,
      updatedAt: reading.updatedAt,
      lastRead: reading.lastRead,
      syncStatus: reading.syncStatus,
      serverId: reading.serverId,
    );
  }
}
