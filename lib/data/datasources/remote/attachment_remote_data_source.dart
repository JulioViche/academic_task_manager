import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../models/attachment_model.dart';

abstract class AttachmentRemoteDataSource {
  Future<AttachmentModel> uploadFile(
    File file,
    String userId, {
    String? taskId,
    String? subjectId,
  });
  Future<List<AttachmentModel>> getAttachments({
    String? taskId,
    String? subjectId,
  });
  Future<void> deleteFile(String attachmentId, String cloudUrl);
}

class AttachmentRemoteDataSourceImpl implements AttachmentRemoteDataSource {
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore; // Added FirebaseFirestore

  // Ideally, metadata should be stored in Firestore, not just Storage.
  // For this sprint/implementation focusing on files, we will assume metadata is handled or stored alongside.
  // However, listing attachments usually requires a database query. This datasource will handle STORAGE operations.

  AttachmentRemoteDataSourceImpl({
    required this.firebaseStorage,
    required this.firebaseFirestore, // Added FirebaseFirestore to constructor
  });

  @override
  Future<AttachmentModel> uploadFile(
    File file,
    String userId, {
    String? taskId,
    String? subjectId,
  }) async {
    try {
      final String fileId = const Uuid().v4();
      final String extension = file.path.split('.').last;
      String path = 'users/$userId/attachments/';

      if (taskId != null) {
        path += 'tasks/$taskId/';
      } else if (subjectId != null) {
        path += 'subjects/$subjectId/';
      }

      path += '$fileId.$extension';

      final ref = firebaseStorage.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      final attachment = AttachmentModel(
        id: fileId,
        taskId: taskId,
        subjectId: subjectId,
        userId: userId,
        fileName: file.path.split('/').last,
        fileType: extension,
        filePath: file.path,
        fileSize: await file.length(),
        cloudUrl: downloadUrl,
        mimeType: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: 'synced',
      );

      // Save metadata to Firestore
      await firebaseFirestore
          .collection('attachments')
          .doc(fileId)
          .set(attachment.toJson());

      return attachment;
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  @override
  Future<List<AttachmentModel>> getAttachments({
    String? taskId,
    String? subjectId,
  }) async {
    try {
      Query query = firebaseFirestore.collection('attachments');

      if (taskId != null) {
        query = query.where('task_id', isEqualTo: taskId);
      } else if (subjectId != null) {
        query = query.where('subject_id', isEqualTo: subjectId);
      } else {
        // If neither taskId nor subjectId is provided, return an empty list
        // or throw an error depending on desired behavior.
        return [];
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) =>
                AttachmentModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Fetch attachments failed: $e');
    }
  }

  @override
  Future<void> deleteFile(String attachmentId, String cloudUrl) async {
    try {
      // Delete from Storage
      final ref = firebaseStorage.refFromURL(cloudUrl);
      await ref.delete();

      // Delete from Firestore
      await firebaseFirestore
          .collection('attachments')
          .doc(attachmentId)
          .delete();
    } catch (e) {
      throw Exception('Delete failed: $e');
    }
  }
}
