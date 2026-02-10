import '../../data/datasources/local/database_helper.dart';

/// Service for computing aggregate statistics across tasks, subjects, and grades
class StatisticsService {
  final DatabaseHelper databaseHelper;

  StatisticsService({required this.databaseHelper});

  /// Get average grade per subject → { subjectId: average }
  Future<Map<String, double>> getAveragesBySubject(String userId) async {
    final db = await databaseHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT subject_id, AVG(score * 1.0 / max_score * 10) as average
      FROM grades WHERE user_id = ?
      GROUP BY subject_id
    ''',
      [userId],
    );

    final map = <String, double>{};
    for (final row in result) {
      final subjectId = row['subject_id'] as String;
      final avg = (row['average'] as num?)?.toDouble() ?? 0.0;
      map[subjectId] = avg;
    }
    return map;
  }

  /// Count of completed tasks
  Future<int> getCompletedTasksCount(String userId) async {
    final db = await databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE user_id = ? AND status = ?',
      [userId, 'completed'],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Count of pending tasks (not completed and not yet overdue)
  Future<int> getPendingTasksCount(String userId) async {
    final db = await databaseHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    // Count tasks that are not completed and (have no due date OR are due in the future)
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM tasks WHERE user_id = ? AND status != 'completed' AND (due_date IS NULL OR due_date >= ?)",
      [userId, now],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Count of overdue tasks (past due_date, not completed)
  Future<int> getOverdueTasksCount(String userId) async {
    final db = await databaseHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM tasks WHERE user_id = ? AND status != 'completed' AND due_date < ?",
      [userId, now],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Completion rate as a percentage (0.0 – 100.0)
  Future<double> getCompletionRate(String userId) async {
    final db = await databaseHelper.database;
    final total = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE user_id = ?',
      [userId],
    );
    final completed = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE user_id = ? AND status = ?',
      [userId, 'completed'],
    );
    final t = (total.first['count'] as int?) ?? 0;
    final c = (completed.first['count'] as int?) ?? 0;
    if (t == 0) return 0.0;
    return (c / t) * 100.0;
  }

  /// Tasks count per subject → { subjectId: count }
  Future<Map<String, int>> getTasksPerSubject(String userId) async {
    final db = await databaseHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT subject_id, COUNT(*) as count
      FROM tasks WHERE user_id = ?
      GROUP BY subject_id
    ''',
      [userId],
    );

    final map = <String, int>{};
    for (final row in result) {
      final subjectId = row['subject_id'] as String;
      final count = (row['count'] as int?) ?? 0;
      map[subjectId] = count;
    }
    return map;
  }

  /// Get upcoming tasks (next 7 days)
  Future<int> getUpcomingTasksCount(String userId) async {
    final db = await databaseHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final weekLater = DateTime.now()
        .add(const Duration(days: 7))
        .millisecondsSinceEpoch;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM tasks WHERE user_id = ? AND status != 'completed' AND due_date >= ? AND due_date <= ?",
      [userId, now, weekLater],
    );
    return (result.first['count'] as int?) ?? 0;
  }
}
