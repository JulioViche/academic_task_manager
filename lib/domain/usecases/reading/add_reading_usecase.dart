import '../../entities/reading_entity.dart';
import '../../repositories/reading_repository.dart';

class AddReadingUseCase {
  final ReadingRepository repository;

  AddReadingUseCase(this.repository);

  Future<void> call(Reading reading) async {
    return await repository.addReading(reading);
  }
}
