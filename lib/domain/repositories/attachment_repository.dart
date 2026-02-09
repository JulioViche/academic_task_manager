import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/attachment_entity.dart';
import 'dart:io';

abstract class AttachmentRepository {
  Future<Either<Failure, Attachment>> uploadAttachment({
    required File file,
    required String userId,
    String? taskId,
    String? subjectId,
  });

  Future<Either<Failure, List<Attachment>>> getAttachments({
    String? taskId,
    String? subjectId,
  });

  Future<Either<Failure, void>> deleteAttachment(String attachmentId);
}
