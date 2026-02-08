import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/constants.dart';
import '../di/di.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Watch the shared preferences provider. When it updates (e.g. loads),
    // this notifier will rebuild its state.
    final prefsAsync = ref.watch(sharedPreferencesProvider);

    return prefsAsync.when(
      data: (prefs) {
        final themeString = prefs.getString(AppConstants.themeKey);
        if (themeString == 'light') {
          return ThemeMode.light;
        } else if (themeString == 'dark') {
          return ThemeMode.dark;
        } else {
          return ThemeMode.system;
        }
      },
      error: (_, __) => ThemeMode.system,
      loading: () => ThemeMode.system,
    );
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    // We can read the current value of sharedPreferencesProvider
    final prefs = ref.read(sharedPreferencesProvider).asData?.value;

    String themeString;
    switch (mode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
    }
    prefs?.setString(AppConstants.themeKey, themeString);
  }

  void toggleTheme() {
    if (state == ThemeMode.light) {
      setTheme(ThemeMode.dark);
    } else {
      setTheme(ThemeMode.light);
    }
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
