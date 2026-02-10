import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_notifier.dart';

final tutorialNotifierProvider =
    StateNotifierProvider<TutorialNotifier, TutorialState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TutorialNotifier(prefs);
});

class TutorialState {
  final bool hasSeenHomeTutorial;
  final bool hasSeenSubjectTutorial;
  final bool hasSeenTasksTutorial;
  final bool hasSeenCalendarTutorial;

  TutorialState({
    required this.hasSeenHomeTutorial,
    required this.hasSeenSubjectTutorial,
    required this.hasSeenTasksTutorial,
    required this.hasSeenCalendarTutorial,
  });

  TutorialState copyWith({
    bool? hasSeenHomeTutorial,
    bool? hasSeenSubjectTutorial,
    bool? hasSeenTasksTutorial,
    bool? hasSeenCalendarTutorial,
  }) {
    return TutorialState(
      hasSeenHomeTutorial: hasSeenHomeTutorial ?? this.hasSeenHomeTutorial,
      hasSeenSubjectTutorial:
          hasSeenSubjectTutorial ?? this.hasSeenSubjectTutorial,
      hasSeenTasksTutorial: hasSeenTasksTutorial ?? this.hasSeenTasksTutorial,
      hasSeenCalendarTutorial:
          hasSeenCalendarTutorial ?? this.hasSeenCalendarTutorial,
    );
  }
}

class TutorialNotifier extends StateNotifier<TutorialState> {
  final SharedPreferences _prefs;

  TutorialNotifier(this._prefs)
      : super(TutorialState(
          hasSeenHomeTutorial: _prefs.getBool('hasSeenHomeTutorial') ?? false,
          hasSeenSubjectTutorial:
              _prefs.getBool('hasSeenSubjectTutorial') ?? false,
          hasSeenTasksTutorial: _prefs.getBool('hasSeenTasksTutorial') ?? false,
          hasSeenCalendarTutorial:
              _prefs.getBool('hasSeenCalendarTutorial') ?? false,
        ));

  Future<void> completeHomeTutorial() async {
    await _prefs.setBool('hasSeenHomeTutorial', true);
    state = state.copyWith(hasSeenHomeTutorial: true);
  }

  Future<void> completeSubjectTutorial() async {
    await _prefs.setBool('hasSeenSubjectTutorial', true);
    state = state.copyWith(hasSeenSubjectTutorial: true);
  }

  Future<void> completeTasksTutorial() async {
    await _prefs.setBool('hasSeenTasksTutorial', true);
    state = state.copyWith(hasSeenTasksTutorial: true);
  }

  Future<void> completeCalendarTutorial() async {
    await _prefs.setBool('hasSeenCalendarTutorial', true);
    state = state.copyWith(hasSeenCalendarTutorial: true);
  }

  Future<void> resetTutorials() async {
    await _prefs.remove('hasSeenHomeTutorial');
    await _prefs.remove('hasSeenSubjectTutorial');
    await _prefs.remove('hasSeenTasksTutorial');
    await _prefs.remove('hasSeenCalendarTutorial');
    state = TutorialState(
      hasSeenHomeTutorial: false,
      hasSeenSubjectTutorial: false,
      hasSeenTasksTutorial: false,
      hasSeenCalendarTutorial: false,
    );
  }
}
