import '../entities/subject_entity.dart';
import '../repositories/subject_repository.dart';

/// Get all subjects for a user
class GetSubjectsUseCase {
  final SubjectRepository repository;

  GetSubjectsUseCase(this.repository);

  Future<List<Subject>> call(String userId) async {
    return repository.getSubjects(userId);
  }
}

/// Add a new subject
class AddSubjectUseCase {
  final SubjectRepository repository;

  AddSubjectUseCase(this.repository);

  Future<void> call(Subject subject) async {
    return repository.addSubject(subject);
  }
}

/// Update an existing subject
class UpdateSubjectUseCase {
  final SubjectRepository repository;

  UpdateSubjectUseCase(this.repository);

  Future<void> call(Subject subject) async {
    return repository.updateSubject(subject);
  }
}

/// Delete a subject
class DeleteSubjectUseCase {
  final SubjectRepository repository;

  DeleteSubjectUseCase(this.repository);

  Future<void> call(String subjectId) async {
    return repository.deleteSubject(subjectId);
  }
}
