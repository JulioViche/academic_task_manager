import '../../data/datasources/local/database_helper.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../data/models/subject_model.dart';
import '../../data/models/task_model.dart';

class SearchResults {
  final List<Subject> subjects;
  final List<Task> tasks;

  const SearchResults({this.subjects = const [], this.tasks = const []});

  bool get isEmpty => subjects.isEmpty && tasks.isEmpty;
}

class SearchService {
  final DatabaseHelper databaseHelper;

  SearchService({required this.databaseHelper});

  Future<SearchResults> search(String query, String userId) async {
    if (query.trim().isEmpty) return const SearchResults();

    final db = await databaseHelper.database;
    final searchTerm = '%$query%';

    // Search Subjects
    final subjectResults = await db.query(
      'subjects',
      where: 'user_id = ? AND (subject_name LIKE ? OR subject_code LIKE ?)',
      whereArgs: [userId, searchTerm, searchTerm],
    );

    // Search Tasks
    final taskResults = await db.query(
      'tasks',
      where: 'user_id = ? AND (title LIKE ? OR description LIKE ?)',
      whereArgs: [userId, searchTerm, searchTerm],
    );

    return SearchResults(
      subjects: subjectResults.map((e) => SubjectModel.fromJson(e)).toList(),
      tasks: taskResults.map((e) => TaskModel.fromJson(e)).toList(),
    );
  }
}
