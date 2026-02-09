import 'package:sqflite/sqflite.dart';
import '../../models/subject_model.dart';
import '../../../core/error/exceptions.dart';
import 'database_helper.dart';

/// Local data source for Subject CRUD operations using SQLite
abstract class SubjectLocalDataSource {
  /// Get all subjects for a user
  Future<List<SubjectModel>> getAllSubjects(String userId);

  /// Get a subject by ID
  Future<SubjectModel?> getSubject(String subjectId);

  /// Insert a new subject
  Future<void> insertSubject(SubjectModel subject);

  /// Update an existing subject
  Future<void> updateSubject(SubjectModel subject);

  /// Delete a subject
  Future<void> deleteSubject(String subjectId);

  /// Archive a subject
  Future<void> archiveSubject(String subjectId);

  /// Get subjects by sync status
  Future<List<SubjectModel>> getSubjectsBySyncStatus(String syncStatus);
}

class SubjectLocalDataSourceImpl implements SubjectLocalDataSource {
  final DatabaseHelper databaseHelper;

  SubjectLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<SubjectModel>> getAllSubjects(String userId) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'subjects',
        where: 'user_id = ? AND is_archived = 0',
        whereArgs: [userId],
        orderBy: 'subject_name ASC',
      );

      return maps.map((map) => SubjectModel.fromJson(map)).toList();
    } catch (e) {
      throw CacheException('Failed to get subjects: ${e.toString()}');
    }
  }

  @override
  Future<SubjectModel?> getSubject(String subjectId) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'subjects',
        where: 'subject_id = ?',
        whereArgs: [subjectId],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return SubjectModel.fromJson(maps.first);
    } catch (e) {
      throw CacheException('Failed to get subject: ${e.toString()}');
    }
  }

  @override
  Future<void> insertSubject(SubjectModel subject) async {
    try {
      final db = await databaseHelper.database;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      final data = subject.toJson();
      data['created_at'] = now;
      data['updated_at'] = now;
      
      await db.insert(
        'subjects',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException('Failed to insert subject: ${e.toString()}');
    }
  }

  @override
  Future<void> updateSubject(SubjectModel subject) async {
    try {
      final db = await databaseHelper.database;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      final data = subject.toJson();
      data['updated_at'] = now;
      data['sync_status'] = 'pending';
      
      await db.update(
        'subjects',
        data,
        where: 'subject_id = ?',
        whereArgs: [subject.id],
      );
    } catch (e) {
      throw CacheException('Failed to update subject: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        'subjects',
        where: 'subject_id = ?',
        whereArgs: [subjectId],
      );
    } catch (e) {
      throw CacheException('Failed to delete subject: ${e.toString()}');
    }
  }

  @override
  Future<void> archiveSubject(String subjectId) async {
    try {
      final db = await databaseHelper.database;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      await db.update(
        'subjects',
        {
          'is_archived': 1,
          'updated_at': now,
          'sync_status': 'pending',
        },
        where: 'subject_id = ?',
        whereArgs: [subjectId],
      );
    } catch (e) {
      throw CacheException('Failed to archive subject: ${e.toString()}');
    }
  }

  @override
  Future<List<SubjectModel>> getSubjectsBySyncStatus(String syncStatus) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'subjects',
        where: 'sync_status = ?',
        whereArgs: [syncStatus],
      );

      return maps.map((map) => SubjectModel.fromJson(map)).toList();
    } catch (e) {
      throw CacheException('Failed to get subjects by sync status: ${e.toString()}');
    }
  }
}
