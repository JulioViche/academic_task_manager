import '../entities/reading_entity.dart';

abstract class ReadingRepository {
  Future<List<Reading>> getReadingsBySubject(String subjectId);
  Future<void> addReading(Reading reading);
  Future<void> updateReading(Reading reading);
  Future<void> deleteReading(String readingId);
  Future<void> updateProgress(
    String readingId,
    int currentPage,
    double progress,
    bool isCompleted,
  );
}
