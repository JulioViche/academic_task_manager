import '../../repositories/reading_repository.dart';

class DeleteReadingUseCase {
  final ReadingRepository repository;

  DeleteReadingUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteReading(id);
  }
}
