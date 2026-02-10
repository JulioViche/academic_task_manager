import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/attachment_entity.dart';
import '../../domain/usecases/attachment/upload_attachment_usecase.dart';
import '../../domain/usecases/attachment/get_attachments_usecase.dart';
import '../../data/repositories/attachment_repository_impl.dart';
import '../../data/datasources/remote/attachment_remote_data_source.dart';
import '../../core/network/network_info.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/datasources/local/attachment_local_data_source.dart';
import 'subject_notifier.dart'; // For databaseHelperProvider

// Dependencies
final firebaseStorageProvider = Provider<FirebaseStorage>(
  (ref) => FirebaseStorage.instance,
);

final firebaseFirestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final attachmentRemoteDataSourceProvider = Provider<AttachmentRemoteDataSource>(
  (ref) {
    return AttachmentRemoteDataSourceImpl(
      firebaseStorage: ref.read(firebaseStorageProvider),
      firebaseFirestore: ref.read(firebaseFirestoreProvider),
    );
  },
);

final networkInfoProvider = Provider<NetworkInfo>(
  (ref) => NetworkInfoImpl(Connectivity()),
);

final attachmentLocalDataSourceProvider = Provider<AttachmentLocalDataSource>((
  ref,
) {
  return AttachmentLocalDataSourceImpl(
    databaseHelper: ref.watch(databaseHelperProvider),
  );
});

final attachmentRepositoryProvider = Provider<AttachmentRepositoryImpl>((ref) {
  return AttachmentRepositoryImpl(
    remoteDataSource: ref.read(attachmentRemoteDataSourceProvider),
    localDataSource: ref.read(attachmentLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

final uploadAttachmentUseCaseProvider = Provider<UploadAttachmentUseCase>((
  ref,
) {
  return UploadAttachmentUseCase(ref.read(attachmentRepositoryProvider));
});

final getAttachmentsUseCaseProvider = Provider<GetAttachmentsUseCase>((ref) {
  return GetAttachmentsUseCase(ref.read(attachmentRepositoryProvider));
});

// State definitions
abstract class AttachmentState {
  const AttachmentState();
}

class AttachmentInitial extends AttachmentState {
  const AttachmentInitial();
}

class AttachmentLoading extends AttachmentState {
  const AttachmentLoading();
}

class AttachmentSuccess extends AttachmentState {
  final Attachment attachment;
  const AttachmentSuccess(this.attachment);
}

class AttachmentsLoaded extends AttachmentState {
  final List<Attachment> attachments;
  const AttachmentsLoaded(this.attachments);
}

class AttachmentError extends AttachmentState {
  final String message;
  const AttachmentError(this.message);
}

// Notifier
class AttachmentNotifier extends StateNotifier<AttachmentState> {
  final UploadAttachmentUseCase _uploadAttachmentUseCase;
  final GetAttachmentsUseCase _getAttachmentsUseCase;

  AttachmentNotifier(this._uploadAttachmentUseCase, this._getAttachmentsUseCase)
    : super(const AttachmentInitial());

  Future<void> uploadFile({
    required File file,
    required String userId,
    String? taskId,
    String? subjectId,
  }) async {
    state = const AttachmentLoading();
    final result = await _uploadAttachmentUseCase(
      UploadAttachmentParams(
        file: file,
        userId: userId,
        taskId: taskId,
        subjectId: subjectId,
      ),
    );

    result.fold(
      (failure) => state = AttachmentError(failure.message),
      (attachment) => state = AttachmentSuccess(attachment),
    );
  }

  Future<void> getAttachments({String? taskId, String? subjectId}) async {
    state = const AttachmentLoading();
    final result = await _getAttachmentsUseCase(
      taskId: taskId,
      subjectId: subjectId,
    );

    result.fold(
      (failure) => state = AttachmentError(failure.message),
      (attachments) => state = AttachmentsLoaded(attachments),
    );
  }
}

final attachmentNotifierProvider =
    StateNotifierProvider<AttachmentNotifier, AttachmentState>((ref) {
      return AttachmentNotifier(
        ref.read(uploadAttachmentUseCaseProvider),
        ref.read(getAttachmentsUseCaseProvider),
      );
    });
