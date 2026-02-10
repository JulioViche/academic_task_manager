import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/reading_local_data_source.dart';
import '../../data/repositories/reading_repository_impl.dart';
import '../../domain/repositories/reading_repository.dart';
import '../../domain/usecases/reading/add_reading_usecase.dart';
import '../../domain/usecases/reading/delete_reading_usecase.dart';
import '../../domain/usecases/reading/get_readings_by_subject_usecase.dart';
import '../../domain/usecases/reading/update_reading_progress_usecase.dart';
import 'subject_notifier.dart'; // for databaseHelperProvider

// ─── Data Source Provider ────────────────────────────────────

final readingLocalDataSourceProvider = Provider<ReadingLocalDataSource>((ref) {
  return ReadingLocalDataSourceImpl(
    databaseHelper: ref.watch(databaseHelperProvider),
  );
});

// ─── Repository Provider ─────────────────────────────────────

final readingRepositoryProvider = Provider<ReadingRepository>((ref) {
  return ReadingRepositoryImpl(
    localDataSource: ref.watch(readingLocalDataSourceProvider),
  );
});

// ─── Use Case Providers ──────────────────────────────────────

final getReadingsBySubjectProvider = Provider<GetReadingsBySubjectUseCase>((
  ref,
) {
  return GetReadingsBySubjectUseCase(ref.watch(readingRepositoryProvider));
});

final addReadingProvider = Provider<AddReadingUseCase>((ref) {
  return AddReadingUseCase(ref.watch(readingRepositoryProvider));
});

final deleteReadingProvider = Provider<DeleteReadingUseCase>((ref) {
  return DeleteReadingUseCase(ref.watch(readingRepositoryProvider));
});

final updateReadingProgressProvider = Provider<UpdateReadingProgressUseCase>((
  ref,
) {
  return UpdateReadingProgressUseCase(ref.watch(readingRepositoryProvider));
});
