import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/attachment_repository.dart';
import '../../entities/attachment_entity.dart';

class GetAttachmentsUseCase {
  final AttachmentRepository repository;

  GetAttachmentsUseCase(this.repository);

  Future<Either<Failure, List<Attachment>>> call({
    String? taskId,
    String? subjectId,
  }) async {
    return await repository.getAttachments(
      taskId: taskId,
      subjectId: subjectId,
    );
  }
}
