import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/subject_entity.dart';
import '../../data/repositories/subject_repository_impl.dart';
import '../../data/datasources/local/subject_local_data_source.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/network/network_info.dart';
import '../../data/datasources/remote/subject_remote_data_source.dart';
import '../../data/datasources/local/database_helper.dart';
import 'sync_provider.dart';

/// State for subjects
class SubjectState {
  final List<Subject> subjects;
  final bool isLoading;
  final String? errorMessage;

  const SubjectState({
    this.subjects = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  SubjectState copyWith({
    List<Subject>? subjects,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SubjectState(
      subjects: subjects ?? this.subjects,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Subject state notifier
class SubjectNotifier extends StateNotifier<SubjectState> {
  final SubjectRepositoryImpl repository;
  String? _currentUserId;

  SubjectNotifier(this.repository) : super(const SubjectState());

  /// Load all subjects for a user
  Future<void> loadSubjects(String userId) async {
    _currentUserId = userId;
    state = state.copyWith(isLoading: true, errorMessage: null);
    print('SubjectNotifier: Loading subjects for user $userId');

    try {
      final subjects = await repository.getSubjects(userId);
      print('SubjectNotifier: Loaded ${subjects.length} subjects');
      state = state.copyWith(subjects: subjects, isLoading: false);
    } catch (e) {
      print('SubjectNotifier: Error loading subjects: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load subjects: ${e.toString()}',
      );
    }
  }

  /// Add a new subject
  Future<bool> addSubject(Subject subject) async {
    try {
      await repository.addSubject(subject);
      if (_currentUserId != null) {
        await loadSubjects(_currentUserId!);
      }
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to add subject: ${e.toString()}',
      );
      return false;
    }
  }

  /// Update a subject
  Future<bool> updateSubject(Subject subject) async {
    try {
      await repository.updateSubject(subject);
      if (_currentUserId != null) {
        await loadSubjects(_currentUserId!);
      }
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to update subject: ${e.toString()}',
      );
      return false;
    }
  }

  /// Delete a subject
  Future<bool> deleteSubject(String subjectId) async {
    try {
      await repository.deleteSubject(subjectId);
      if (_currentUserId != null) {
        await loadSubjects(_currentUserId!);
      }
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to delete subject: ${e.toString()}',
      );
      return false;
    }
  }

  /// Archive a subject
  Future<bool> archiveSubject(String subjectId) async {
    try {
      await repository.archiveSubject(subjectId);
      if (_currentUserId != null) {
        await loadSubjects(_currentUserId!);
      }
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to archive subject: ${e.toString()}',
      );
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Providers
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final subjectLocalDataSourceProvider = Provider<SubjectLocalDataSource>((ref) {
  return SubjectLocalDataSourceImpl(
    databaseHelper: ref.watch(databaseHelperProvider),
  );
});

final subjectRemoteDataSourceProvider = Provider<SubjectRemoteDataSource>((
  ref,
) {
  return SubjectRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
});

final subjectRepositoryProvider = Provider<SubjectRepositoryImpl>((ref) {
  return SubjectRepositoryImpl(
    localDataSource: ref.watch(subjectLocalDataSourceProvider),
    remoteDataSource: ref.watch(subjectRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
    syncQueue: ref.watch(syncQueueDataSourceProvider),
  );
});

final subjectNotifierProvider =
    StateNotifierProvider<SubjectNotifier, SubjectState>((ref) {
      return SubjectNotifier(ref.watch(subjectRepositoryProvider));
    });
