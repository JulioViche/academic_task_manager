import '../../models/attachment_model.dart';
import 'database_helper.dart';

abstract class AttachmentLocalDataSource {
  Future<void> insertAttachment(AttachmentModel attachment);
  Future<List<AttachmentModel>> getAttachmentsByTask(String taskId);
  Future<List<AttachmentModel>> getAttachmentsBySubject(String subjectId);
  Future<void> deleteAttachment(String attachmentId);
  Future<void> updateAttachment(AttachmentModel attachment);
  Future<AttachmentModel?> getAttachment(String attachmentId);
}

class AttachmentLocalDataSourceImpl implements AttachmentLocalDataSource {
  final DatabaseHelper databaseHelper;

  AttachmentLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<void> insertAttachment(AttachmentModel attachment) async {
    final db = await databaseHelper.database;
    await db.insert('attachments', attachment.toJson());
  }

  @override
  Future<List<AttachmentModel>> getAttachmentsByTask(String taskId) async {
    final db = await databaseHelper.database;
    final result = await db.query(
      'attachments',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'created_at DESC',
    );
    return result.map((e) => AttachmentModel.fromJson(e)).toList();
  }

  @override
  Future<List<AttachmentModel>> getAttachmentsBySubject(
    String subjectId,
  ) async {
    final db = await databaseHelper.database;
    final result = await db.query(
      'attachments',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'created_at DESC',
    );
    return result.map((e) => AttachmentModel.fromJson(e)).toList();
  }

  @override
  Future<void> deleteAttachment(String attachmentId) async {
    final db = await databaseHelper.database;
    await db.delete(
      'attachments',
      where: 'attachment_id = ?',
      whereArgs: [attachmentId],
    );
  }

  @override
  Future<void> updateAttachment(AttachmentModel attachment) async {
    final db = await databaseHelper.database;
    await db.update(
      'attachments',
      attachment.toJson(),
      where: 'attachment_id = ?',
      whereArgs: [attachment.id],
    );
  }

  @override
  Future<AttachmentModel?> getAttachment(String attachmentId) async {
    final db = await databaseHelper.database;
    final result = await db.query(
      'attachments',
      where: 'attachment_id = ?',
      whereArgs: [attachmentId],
    );
    if (result.isNotEmpty) {
      return AttachmentModel.fromJson(result.first);
    }
    return null;
  }
}
