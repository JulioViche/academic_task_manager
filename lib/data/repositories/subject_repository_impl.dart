import '../../domain/entities/subject_entity.dart';
import '../../domain/repositories/subject_repository.dart';
import '../datasources/local/subject_local_data_source.dart';
import '../models/subject_model.dart';
import '../../core/error/exceptions.dart';

/// Implementation of SubjectRepository using local data source
class SubjectRepositoryImpl implements SubjectRepository {
  final SubjectLocalDataSource localDataSource;

  SubjectRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Subject>> getSubjects(String userId) async {
    try {
      final subjects = await localDataSource.getAllSubjects(userId);
      return subjects;
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to get subjects: ${e.toString()}');
    }
  }

  @override
  Future<void> addSubject(Subject subject) async {
    try {
      final subjectModel = SubjectModel.fromEntity(subject);
      await localDataSource.insertSubject(subjectModel);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to add subject: ${e.toString()}');
    }
  }

  @override
  Future<void> updateSubject(Subject subject) async {
    try {
      final subjectModel = SubjectModel.fromEntity(subject);
      await localDataSource.updateSubject(subjectModel);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to update subject: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    try {
      await localDataSource.deleteSubject(subjectId);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to delete subject: ${e.toString()}');
    }
  }

  /// Archive a subject instead of deleting
  Future<void> archiveSubject(String subjectId) async {
    try {
      await localDataSource.archiveSubject(subjectId);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to archive subject: ${e.toString()}');
    }
  }

  /// Get a single subject by ID
  Future<Subject?> getSubjectById(String subjectId) async {
    try {
      return await localDataSource.getSubject(subjectId);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to get subject: ${e.toString()}');
    }
  }
}
