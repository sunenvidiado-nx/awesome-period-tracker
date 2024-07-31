import 'package:awesome_period_tracker/core/providers/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  // Generate random strings here: http://bit.ly/random-strings-generator
  static const _prefsKey = 'yNLV1XGjsDaV';

  @override
  ThemeMode build() {
    final isDark =
        ref.read(sharedPreferencesProvider).getBool(_prefsKey) ?? false;

    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      ref.read(sharedPreferencesProvider).setBool(_prefsKey, false);
    } else {
      ref.read(sharedPreferencesProvider).setBool(_prefsKey, true);
    }

    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
