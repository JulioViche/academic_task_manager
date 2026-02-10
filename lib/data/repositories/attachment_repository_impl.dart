import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/network_info.dart';

import '../../domain/repositories/attachment_repository.dart';
import '../../domain/entities/attachment_entity.dart';
import '../datasources/remote/attachment_remote_data_source.dart';

import '../datasources/local/attachment_local_data_source.dart';
import '../../data/models/attachment_model.dart';
import 'package:uuid/uuid.dart';

class AttachmentRepositoryImpl implements AttachmentRepository {
  final AttachmentRemoteDataSource remoteDataSource;
  final AttachmentLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AttachmentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  String _mapFileType(String extension) {
    extension = extension.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      return 'image';
    } else if (extension == 'pdf') {
      return 'pdf';
    } else if ([
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'txt',
    ].contains(extension)) {
      return 'document';
    } else {
      return 'other';
    }
  }

  @override
  Future<Either<Failure, Attachment>> uploadAttachment({
    required File file,
    required String userId,
    String? taskId,
    String? subjectId,
  }) async {
    final extension = file.path.split('.').last;
    final fileType = _mapFileType(extension);

    // 1. Create initial local model (optimistic UI)
    final localAttachment = AttachmentModel(
      id: const Uuid().v4(),
      taskId: taskId,
      subjectId: subjectId,
      userId: userId,
      fileName: file.uri.pathSegments.last,
      fileType: fileType,
      filePath: file.path,
      fileSize: await file.length(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: 'pending',
    );

    try {
      // 2. Save locally first
      await localDataSource.insertAttachment(localAttachment);

      if (await networkInfo.isConnected) {
        try {
          // 3. Attempt upload
          final uploadedAttachment = await remoteDataSource.uploadFile(
            file,
            userId,
            taskId: taskId,
            subjectId: subjectId,
          );

          // 4. Update local with cloud URL and synced status
          final updatedModel = AttachmentModel(
            id: localAttachment.id, // Keep local ID
            taskId: taskId,
            subjectId: subjectId,
            userId: userId,
            fileName: uploadedAttachment.fileName,
            fileType: _mapFileType(
              uploadedAttachment.fileType,
            ), // Ensure mapped type
            filePath: file.path, // Keep local path
            fileSize: uploadedAttachment.fileSize,
            cloudUrl: uploadedAttachment.cloudUrl,
            mimeType: uploadedAttachment.mimeType,
            thumbnailPath: uploadedAttachment.thumbnailPath,
            createdAt: localAttachment.createdAt,
            updatedAt: DateTime.now(),
            syncStatus: 'synced',
            serverId: uploadedAttachment.id, // Map remote ID if any
          );

          await localDataSource.updateAttachment(updatedModel);
          return Right(updatedModel);
        } on ServerException {
          return Right(localAttachment);
        } catch (e) {
          return Right(localAttachment);
        }
      } else {
        // Offline: Already saved locally as pending.
        return Right(localAttachment);
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Attachment>>> getAttachments({
    String? taskId,
    String? subjectId,
  }) async {
    try {
      // 1. Fetch from local DB
      List<AttachmentModel> localAttachments = [];
      if (taskId != null) {
        localAttachments = await localDataSource.getAttachmentsByTask(taskId);
      } else if (subjectId != null) {
        localAttachments = await localDataSource.getAttachmentsBySubject(
          subjectId,
        );
      }

      // 2. Sync with Remote if online
      if (await networkInfo.isConnected) {
        try {
          final remoteAttachments = await remoteDataSource.getAttachments(
            taskId: taskId,
            subjectId: subjectId,
          );

          for (final remoteAttachment in remoteAttachments) {
            final isLocal = localAttachments.any(
              (local) => local.id == remoteAttachment.id,
            );

            if (!isLocal) {
              // Not in local DB, insert it.
              final newLocalAttachment = AttachmentModel(
                id: remoteAttachment.id,
                taskId: remoteAttachment.taskId,
                subjectId: remoteAttachment.subjectId,
                userId: remoteAttachment.userId,
                fileName: remoteAttachment.fileName,
                fileType: _mapFileType(
                  remoteAttachment.fileType,
                ), // Ensure mapped type
                filePath: '', // Empty path indicates not available locally
                fileSize: remoteAttachment.fileSize,
                cloudUrl: remoteAttachment.cloudUrl,
                mimeType: remoteAttachment.mimeType,
                thumbnailPath: remoteAttachment.thumbnailPath,
                createdAt: remoteAttachment.createdAt,
                updatedAt: remoteAttachment.updatedAt,
                syncStatus: 'synced',
                serverId: remoteAttachment.id,
              );

              await localDataSource.insertAttachment(newLocalAttachment);
              localAttachments.add(newLocalAttachment);
            } else {
              // Exists locally.
            }
          }
        } catch (e) {
          // If remote fetch fails, just return local (silent failure) or log it.
        }
      }

      return Right(localAttachments);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAttachment(String attachmentId) async {
    try {
      // 1. Delete locally
      await localDataSource.deleteAttachment(attachmentId);

      // 2. Try delete remote
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.deleteFile(attachmentId, attachmentId);
        } catch (_) {}
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
