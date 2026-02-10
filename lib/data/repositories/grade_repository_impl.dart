import '../../domain/entities/grade_entity.dart';
import '../../domain/repositories/grade_repository.dart';
import '../datasources/local/grade_local_data_source.dart';
import '../models/grade_model.dart';

class GradeRepositoryImpl implements GradeRepository {
  final GradeLocalDataSource localDataSource;

  GradeRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Grade>> getGradesBySubject(String subjectId) async {
    return await localDataSource.getGradesBySubject(subjectId);
  }

  @override
  Future<List<Grade>> getAllGrades(String userId) async {
    return await localDataSource.getAllGrades(userId);
  }

  @override
  Future<void> addGrade(Grade grade) async {
    final model = GradeModel.fromEntity(grade);
    await localDataSource.insertGrade(model);
  }

  @override
  Future<void> updateGrade(Grade grade) async {
    final model = GradeModel.fromEntity(grade);
    await localDataSource.updateGrade(model);
  }

  @override
  Future<void> deleteGrade(String gradeId) async {
    await localDataSource.deleteGrade(gradeId);
  }

  @override
  Future<double> getAverageBySubject(String subjectId) async {
    return await localDataSource.getAverageBySubject(subjectId);
  }
}
