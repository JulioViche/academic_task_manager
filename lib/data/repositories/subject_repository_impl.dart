import 'dart:convert';
import 'dart:developer';
import '../../core/network/network_info.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/repositories/subject_repository.dart';
import '../datasources/local/subject_local_data_source.dart';
import '../datasources/local/sync_queue_local_data_source.dart';
import '../datasources/remote/subject_remote_data_source.dart';
import '../models/subject_model.dart';
import '../models/sync_operation_model.dart';
import '../../core/error/exceptions.dart';

/// Implementation of SubjectRepository using local and remote data sources
class SubjectRepositoryImpl implements SubjectRepository {
  final SubjectLocalDataSource localDataSource;
  final SubjectRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final SyncQueueLocalDataSource syncQueue;

  SubjectRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.syncQueue,
  });

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

      // 1. Save to Local DB
      await localDataSource.insertSubject(subjectModel);

      // 2. Try to sync to Remote DB
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.addSubject(subjectModel);
        } catch (e) {
          // Remote failed → enqueue for later sync
          log('Failed to sync addSubject to remote, queuing: $e');
          await _enqueueOperation('create', subjectModel);
        }
      } else {
        // Offline → enqueue for sync when network returns
        await _enqueueOperation('create', subjectModel);
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

      // 2. Try to sync to Remote DB
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.updateSubject(subjectModel);
        } catch (e) {
          log('Failed to sync updateSubject to remote, queuing: $e');
          await _enqueueOperation('update', subjectModel);
        }
      } else {
        await _enqueueOperation('update', subjectModel);
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

      // 2. Try to sync to Remote DB
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.deleteSubject(subjectId);
        } catch (e) {
          log('Failed to sync deleteSubject to remote, queuing: $e');
          await _enqueueDeleteOperation(subjectId);
        }
      } else {
        await _enqueueDeleteOperation(subjectId);
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

      if (await networkInfo.isConnected) {
        try {
          final subject = await localDataSource.getSubject(subjectId);
          if (subject != null) {
            await remoteDataSource.updateSubject(subject);
          }
        } catch (e) {
          log('Failed to sync archiveSubject to remote, queuing: $e');
          final subject = await localDataSource.getSubject(subjectId);
          if (subject != null) {
            await _enqueueOperation('update', subject);
          }
        }
      } else {
        final subject = await localDataSource.getSubject(subjectId);
        if (subject != null) {
          await _enqueueOperation('update', subject);
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

  /// Helper: enqueue a create/update operation for a subject
  Future<void> _enqueueOperation(String type, SubjectModel model) async {
    try {
      await syncQueue.addToQueue(SyncOperationModel.create(
        tableName: 'subjects',
        recordId: model.id,
        operationType: type,
        jsonData: json.encode(model.toJson()),
      ));
    } catch (e) {
      log('Failed to enqueue subject operation: $e');
    }
  }

  /// Helper: enqueue a delete operation for a subject
  Future<void> _enqueueDeleteOperation(String subjectId) async {
    try {
      await syncQueue.addToQueue(SyncOperationModel.create(
        tableName: 'subjects',
        recordId: subjectId,
        operationType: 'delete',
      ));
    } catch (e) {
      log('Failed to enqueue subject delete operation: $e');
    }
  }
}
