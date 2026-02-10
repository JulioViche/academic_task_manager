import '../../repositories/reading_repository.dart';

class UpdateReadingProgressUseCase {
  final ReadingRepository repository;

  UpdateReadingProgressUseCase(this.repository);

  Future<void> call(
    String id,
    int currentPage,
    double progress,
    bool isCompleted,
  ) async {
    return await repository.updateProgress(
      id,
      currentPage,
      progress,
      isCompleted,
    );
  }
}
