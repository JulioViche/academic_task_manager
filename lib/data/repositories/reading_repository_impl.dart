import '../../domain/entities/reading_entity.dart';
import '../../domain/repositories/reading_repository.dart';
import '../datasources/local/reading_local_data_source.dart';
import '../models/reading_model.dart';

class ReadingRepositoryImpl implements ReadingRepository {
  final ReadingLocalDataSource localDataSource;

  ReadingRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Reading>> getReadingsBySubject(String subjectId) async {
    return await localDataSource.getReadingsBySubject(subjectId);
  }

  @override
  Future<void> addReading(Reading reading) async {
    final readingModel = ReadingModel.fromEntity(reading);
    await localDataSource.insertReading(readingModel);
  }

  @override
  Future<void> updateReading(Reading reading) async {
    final readingModel = ReadingModel.fromEntity(reading);
    await localDataSource.updateReading(readingModel);
  }

  @override
  Future<void> deleteReading(String readingId) async {
    await localDataSource.deleteReading(readingId);
  }

  @override
  Future<void> updateProgress(
    String readingId,
    int currentPage,
    double progress,
    bool isCompleted,
  ) async {
    await localDataSource.updateProgress(
      readingId,
      currentPage,
      progress,
      isCompleted,
    );
  }
}
