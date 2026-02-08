import '../entities/subject_entity.dart';
import '../repositories/subject_repository.dart';

class GetSubjectsUseCase {
  final SubjectRepository repository;

  GetSubjectsUseCase(this.repository);

  Future<List<Subject>> call(String userId) async {
    return repository.getSubjects(userId);
  }
}

class AddSubjectUseCase {
  final SubjectRepository repository;

  AddSubjectUseCase(this.repository);

  Future<void> call(Subject subject) async {
    return repository.addSubject(subject);
  }
}
