import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/grade_local_data_source.dart';
import '../../data/datasources/notification_local_data_source.dart';
import '../../data/repositories/grade_repository_impl.dart';
import '../../core/services/statistics_service.dart';
import '../../core/services/notification_service.dart';
import 'subject_notifier.dart'; // for databaseHelperProvider
import 'grade_notifier.dart';
import 'notification_notifier.dart';

// ─── Data Source Providers ────────────────────────────────────

final gradeLocalDataSourceProvider = Provider<GradeLocalDataSource>((ref) {
  return GradeLocalDataSourceImpl(
    databaseHelper: ref.watch(databaseHelperProvider),
  );
});

final notificationLocalDataSourceProvider =
    Provider<NotificationLocalDataSource>((ref) {
  return NotificationLocalDataSourceImpl(
    databaseHelper: ref.watch(databaseHelperProvider),
  );
});

// ─── Repository Providers ────────────────────────────────────

final gradeRepositoryProvider = Provider<GradeRepositoryImpl>((ref) {
  return GradeRepositoryImpl(
    localDataSource: ref.watch(gradeLocalDataSourceProvider),
  );
});

// ─── Service Providers ───────────────────────────────────────

final statisticsServiceProvider = Provider<StatisticsService>((ref) {
  return StatisticsService(
    databaseHelper: ref.watch(databaseHelperProvider),
  );
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// ─── State Notifier Providers ────────────────────────────────

final gradeNotifierProvider =
    StateNotifierProvider<GradeNotifier, GradeState>((ref) {
  return GradeNotifier(
    repository: ref.watch(gradeRepositoryProvider),
  );
});

final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(
    dataSource: ref.watch(notificationLocalDataSourceProvider),
  );
});
