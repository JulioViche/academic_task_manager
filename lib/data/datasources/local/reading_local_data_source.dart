import '../../models/reading_model.dart';
import 'database_helper.dart';

abstract class ReadingLocalDataSource {
  Future<List<ReadingModel>> getReadingsBySubject(String subjectId);
  Future<void> insertReading(ReadingModel reading);
  Future<void> updateReading(ReadingModel reading);
  Future<void> deleteReading(String readingId);
  Future<void> updateProgress(
    String readingId,
    int currentPage,
    double progress,
    bool isCompleted,
  );
}

class ReadingLocalDataSourceImpl implements ReadingLocalDataSource {
  final DatabaseHelper databaseHelper;

  ReadingLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<ReadingModel>> getReadingsBySubject(String subjectId) async {
    final db = await databaseHelper.database;
    final result = await db.query(
      'readings',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'created_at DESC',
    );
    return result.map((e) => ReadingModel.fromJson(e)).toList();
  }

  @override
  Future<void> insertReading(ReadingModel reading) async {
    final db = await databaseHelper.database;
    await db.insert('readings', reading.toJson());
  }

  @override
  Future<void> updateReading(ReadingModel reading) async {
    final db = await databaseHelper.database;
    await db.update(
      'readings',
      reading.toJson(),
      where: 'reading_id = ?',
      whereArgs: [reading.id],
    );
  }

  @override
  Future<void> deleteReading(String readingId) async {
    final db = await databaseHelper.database;
    await db.delete(
      'readings',
      where: 'reading_id = ?',
      whereArgs: [readingId],
    );
  }

  @override
  Future<void> updateProgress(
    String readingId,
    int currentPage,
    double progress,
    bool isCompleted,
  ) async {
    final db = await databaseHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.update(
      'readings',
      {
        'current_page': currentPage,
        'reading_progress': progress,
        'is_completed': isCompleted ? 1 : 0,
        'last_read': now,
        'updated_at': now,
        'sync_status': 'pending', // Mark as pending sync on update
      },
      where: 'reading_id = ?',
      whereArgs: [readingId],
    );
  }
}
