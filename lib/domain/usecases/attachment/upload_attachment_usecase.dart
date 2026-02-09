import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
// Ensure UseCase is generic and defined
import '../../repositories/attachment_repository.dart';
import '../../entities/attachment_entity.dart';

class UploadAttachmentUseCase {
  final AttachmentRepository repository;

  UploadAttachmentUseCase(this.repository);

  Future<Either<Failure, Attachment>> call(
    UploadAttachmentParams params,
  ) async {
    return await repository.uploadAttachment(
      file: params.file,
      userId: params.userId,
      taskId: params.taskId,
      subjectId: params.subjectId,
    );
  }
}

class UploadAttachmentParams {
  final File file;
  final String userId;
  final String? taskId;
  final String? subjectId;

  UploadAttachmentParams({
    required this.file,
    required this.userId,
    this.taskId,
    this.subjectId,
  });
}
