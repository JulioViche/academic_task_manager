import '../../entities/reading_entity.dart';
import '../../repositories/reading_repository.dart';

class GetReadingsBySubjectUseCase {
  final ReadingRepository repository;

  GetReadingsBySubjectUseCase(this.repository);

  Future<List<Reading>> call(String subjectId) async {
    return await repository.getReadingsBySubject(subjectId);
  }
}
