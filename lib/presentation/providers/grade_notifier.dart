import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/grade_entity.dart';
import '../../data/models/grade_model.dart';
import '../../domain/repositories/grade_repository.dart';
import 'package:uuid/uuid.dart';

// ─── State ──────────────────────────────────────────────

class GradeState {
  final List<Grade> grades;
  final Map<String, double> averages; // subjectId → average
  final bool isLoading;
  final String? errorMessage;

  const GradeState({
    this.grades = const [],
    this.averages = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  GradeState copyWith({
    List<Grade>? grades,
    Map<String, double>? averages,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GradeState(
      grades: grades ?? this.grades,
      averages: averages ?? this.averages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ─── Notifier ───────────────────────────────────────────

class GradeNotifier extends StateNotifier<GradeState> {
  final GradeRepository repository;

  GradeNotifier({required this.repository}) : super(const GradeState());

  Future<void> loadGradesBySubject(String subjectId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final grades = await repository.getGradesBySubject(subjectId);
      final average = await repository.getAverageBySubject(subjectId);
      final newAverages = Map<String, double>.from(state.averages);
      newAverages[subjectId] = average;
      state = state.copyWith(
        grades: grades,
        averages: newAverages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadAllGrades(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final grades = await repository.getAllGrades(userId);
      state = state.copyWith(grades: grades, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> addGrade({
    required String subjectId,
    required String userId,
    required String gradeType,
    required String gradeName,
    required double score,
    required double maxScore,
    double? percentage,
    double weight = 1.0,
    required DateTime date,
    String? notes,
  }) async {
    try {
      final now = DateTime.now();
      final grade = GradeModel(
        id: const Uuid().v4(),
        subjectId: subjectId,
        userId: userId,
        gradeType: gradeType,
        gradeName: gradeName,
        score: score,
        maxScore: maxScore,
        percentage: percentage ?? (score / maxScore * 100),
        weight: weight,
        date: date,
        notes: notes,
        createdAt: now,
        updatedAt: now,
        syncStatus: 'pending',
      );
      await repository.addGrade(grade);
      await loadGradesBySubject(subjectId);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> deleteGrade(String gradeId, String subjectId) async {
    try {
      await repository.deleteGrade(gradeId);
      await loadGradesBySubject(subjectId);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  double getAverageForSubject(String subjectId) {
    return state.averages[subjectId] ?? 0.0;
  }
}
