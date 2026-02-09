import 'dart:developer';
import '../../core/network/network_info.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/repositories/subject_repository.dart';
import '../datasources/local/subject_local_data_source.dart';
import '../datasources/remote/subject_remote_data_source.dart';
import '../models/subject_model.dart';
import '../../core/error/exceptions.dart';

/// Implementation of SubjectRepository using local and remote data sources
class SubjectRepositoryImpl implements SubjectRepository {
  final SubjectLocalDataSource localDataSource;
  final SubjectRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SubjectRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<Subject>> getSubjects(String userId) async {
    try {
      // Offline-first: Get from local DB first for speed
      final subjects = await localDataSource.getAllSubjects(userId);

      // If connected, try to sync from remote (optional strategy: background sync is better)
      // For this implementation, we focus on write-sync.
      // Read-sync could happen here if we want to ensure freshness,
      // but usually we rely on local + background sync.

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

      // 1. Save to Local DB
      await localDataSource.insertSubject(subjectModel);

      // 2. If online, Save to Remote DB
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.addSubject(subjectModel);
        } catch (e) {
          // If remote fails, we just log/ignore for now (it's saved locally)
          // In a real app, we'd add to a sync queue
          log('Failed to sync addSubject to remote: $e');
        }
      }
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

      // 1. Update Local DB
      await localDataSource.updateSubject(subjectModel);

      // 2. If online, Update Remote DB
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.updateSubject(subjectModel);
        } catch (e) {
          log('Failed to sync updateSubject to remote: $e');
        }
      }
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to update subject: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    try {
      // 1. Delete from Local DB
      await localDataSource.deleteSubject(subjectId);

      // 2. If online, Delete from Remote DB
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.deleteSubject(subjectId);
        } catch (e) {
          log('Failed to sync deleteSubject to remote: $e');
        }
      }
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to delete subject: ${e.toString()}');
    }
  }

  /// Archive a subject instead of deleting
  @override
  Future<void> archiveSubject(String subjectId) async {
    try {
      await localDataSource.archiveSubject(subjectId);
      // Note: archiveSubject in local datasource likely updates 'is_archived' flag.
      // If so, we should probably fetch the updated subject and sync it.
      // However, SubjectLocalDataSource.archiveSubject returns void.
      // We would need to fetch the subject again to sync the change,
      // or duplicate the update logic here.

      // For simplicity/safety, let's fetch the subject and update remote if possible.
      if (await networkInfo.isConnected) {
        final subject = await localDataSource.getSubject(subjectId);
        if (subject != null) {
          await remoteDataSource.updateSubject(subject);
        }
      }
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to archive subject: ${e.toString()}');
    }
  }

  /// Get a single subject by ID
  @override
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
