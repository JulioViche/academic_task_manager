import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/subject_model.dart';

abstract class SubjectRemoteDataSource {
  Future<void> addSubject(SubjectModel subject);
  Future<void> updateSubject(SubjectModel subject);
  Future<void> deleteSubject(String subjectId);
  Future<List<SubjectModel>> getSubjects(String userId);
}

class SubjectRemoteDataSourceImpl implements SubjectRemoteDataSource {
  final FirebaseFirestore firestore;

  SubjectRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> addSubject(SubjectModel subject) async {
    try {
      await firestore
          .collection('subjects')
          .doc(subject.id)
          .set(subject.toJson());
    } catch (e) {
      throw Exception('Failed to add subject to remote: $e');
    }
  }

  @override
  Future<void> updateSubject(SubjectModel subject) async {
    try {
      await firestore
          .collection('subjects')
          .doc(subject.id)
          .update(subject.toJson());
    } catch (e) {
      throw Exception('Failed to update subject in remote: $e');
    }
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    try {
      await firestore.collection('subjects').doc(subjectId).delete();
    } catch (e) {
      throw Exception('Failed to delete subject from remote: $e');
    }
  }

  @override
  Future<List<SubjectModel>> getSubjects(String userId) async {
    try {
      final snapshot = await firestore
          .collection('subjects')
          .where('user_id', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => SubjectModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get subjects from remote: $e');
    }
  }
}
