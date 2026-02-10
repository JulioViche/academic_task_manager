import '../../models/grade_model.dart';
import 'database_helper.dart';
import '../../../core/error/exceptions.dart';

// ─── Interface ──────────────────────────────────────────

abstract class GradeLocalDataSource {
  Future<List<GradeModel>> getGradesBySubject(String subjectId);
  Future<List<GradeModel>> getAllGrades(String userId);
  Future<GradeModel> getGrade(String gradeId);
  Future<void> insertGrade(GradeModel grade);
  Future<void> updateGrade(GradeModel grade);
  Future<void> deleteGrade(String gradeId);
  Future<double> getAverageBySubject(String subjectId);
}

// ─── Implementation ─────────────────────────────────────

class GradeLocalDataSourceImpl implements GradeLocalDataSource {
  final DatabaseHelper databaseHelper;

  GradeLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<GradeModel>> getGradesBySubject(String subjectId) async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query(
        'grades',
        where: 'subject_id = ?',
        whereArgs: [subjectId],
        orderBy: 'date DESC',
      );
      return maps.map((m) => GradeModel.fromJson(m)).toList();
    } catch (e) {
      throw CacheException('Failed to get grades: ${e.toString()}');
    }
  }

  @override
  Future<List<GradeModel>> getAllGrades(String userId) async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query(
        'grades',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'date DESC',
      );
      return maps.map((m) => GradeModel.fromJson(m)).toList();
    } catch (e) {
      throw CacheException('Failed to get all grades: ${e.toString()}');
    }
  }

  @override
  Future<GradeModel> getGrade(String gradeId) async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query(
        'grades',
        where: 'grade_id = ?',
        whereArgs: [gradeId],
      );
      if (maps.isEmpty) {
        throw CacheException('Grade not found');
      }
      return GradeModel.fromJson(maps.first);
    } catch (e) {
      throw CacheException('Failed to get grade: ${e.toString()}');
    }
  }

  @override
  Future<void> insertGrade(GradeModel grade) async {
    try {
      final db = await databaseHelper.database;
      await db.insert('grades', grade.toJson());
    } catch (e) {
      throw CacheException('Failed to insert grade: ${e.toString()}');
    }
  }

  @override
  Future<void> updateGrade(GradeModel grade) async {
    try {
      final db = await databaseHelper.database;
      final data = grade.toJson();
      data['sync_status'] = 'pending';
      data['updated_at'] = DateTime.now().millisecondsSinceEpoch;
      await db.update(
        'grades',
        data,
        where: 'grade_id = ?',
        whereArgs: [grade.id],
      );
    } catch (e) {
      throw CacheException('Failed to update grade: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteGrade(String gradeId) async {
    try {
      final db = await databaseHelper.database;
      await db.delete('grades', where: 'grade_id = ?', whereArgs: [gradeId]);
    } catch (e) {
      throw CacheException('Failed to delete grade: ${e.toString()}');
    }
  }

  @override
  Future<double> getAverageBySubject(String subjectId) async {
    try {
      final db = await databaseHelper.database;
      final result = await db.rawQuery(
        'SELECT AVG(score * 1.0 / max_score * 10) as average FROM grades WHERE subject_id = ?',
        [subjectId],
      );
      if (result.isEmpty || result.first['average'] == null) {
        return 0.0;
      }
      return (result.first['average'] as num).toDouble();
    } catch (e) {
      throw CacheException('Failed to get average: ${e.toString()}');
    }
  }
}
