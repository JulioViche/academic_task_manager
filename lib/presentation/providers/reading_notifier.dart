import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reading_entity.dart';
import '../../domain/usecases/reading/add_reading_usecase.dart';
import '../../domain/usecases/reading/delete_reading_usecase.dart';
import '../../domain/usecases/reading/get_readings_by_subject_usecase.dart';
import '../../domain/usecases/reading/update_reading_progress_usecase.dart';
import 'reading_providers.dart';

// ─── State ───────────────────────────────────────────────────

class ReadingState {
  final List<Reading> readings;
  final bool isLoading;
  final String? error;

  const ReadingState({
    this.readings = const [],
    this.isLoading = false,
    this.error,
  });

  ReadingState copyWith({
    List<Reading>? readings,
    bool? isLoading,
    String? error,
  }) {
    return ReadingState(
      readings: readings ?? this.readings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ─── Notifier ────────────────────────────────────────────────

class ReadingNotifier extends StateNotifier<ReadingState> {
  final GetReadingsBySubjectUseCase getReadings;
  final AddReadingUseCase addReading;
  final DeleteReadingUseCase deleteReading;
  final UpdateReadingProgressUseCase updateProgress;

  ReadingNotifier({
    required this.getReadings,
    required this.addReading,
    required this.deleteReading,
    required this.updateProgress,
  }) : super(const ReadingState());

  Future<void> loadReadings(String subjectId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final readings = await getReadings(subjectId);
      state = state.copyWith(readings: readings, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> add(Reading reading) async {
    try {
      await addReading(reading);
      await loadReadings(reading.subjectId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> delete(String readingId, String subjectId) async {
    try {
      await deleteReading(readingId);
      await loadReadings(subjectId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateReadingProgress(
    String readingId,
    String subjectId,
    int currentPage,
    double progress,
    bool isCompleted,
  ) async {
    try {
      await updateProgress(readingId, currentPage, progress, isCompleted);
      await loadReadings(subjectId);
    } catch (e) {
      // Optimitic update fail?
    }
  }
}

// ─── Provider ────────────────────────────────────────────────

final readingNotifierProvider =
    StateNotifierProvider<ReadingNotifier, ReadingState>((ref) {
      return ReadingNotifier(
        getReadings: ref.watch(getReadingsBySubjectProvider),
        addReading: ref.watch(addReadingProvider),
        deleteReading: ref.watch(deleteReadingProvider),
        updateProgress: ref.watch(updateReadingProgressProvider),
      );
    });
