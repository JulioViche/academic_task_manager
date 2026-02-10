import '../entities/grade_entity.dart';

abstract class GradeRepository {
  Future<List<Grade>> getGradesBySubject(String subjectId);
  Future<List<Grade>> getAllGrades(String userId);
  Future<void> addGrade(Grade grade);
  Future<void> updateGrade(Grade grade);
  Future<void> deleteGrade(String gradeId);
  Future<double> getAverageBySubject(String subjectId);
}
