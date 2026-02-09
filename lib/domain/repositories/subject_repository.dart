import '../entities/subject_entity.dart';

abstract class SubjectRepository {
  Future<List<Subject>> getSubjects(String userId);
  Future<void> addSubject(Subject subject);
  Future<void> updateSubject(Subject subject);
  Future<void> deleteSubject(String subjectId);
  Future<void> archiveSubject(String subjectId);
  Future<Subject?> getSubjectById(String subjectId);
}
