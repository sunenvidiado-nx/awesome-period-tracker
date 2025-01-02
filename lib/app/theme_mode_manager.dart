import 'package:awesome_period_tracker/app/state/state_manager.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@singleton
class ThemeModeManager extends StateManager<ThemeMode> {
  ThemeModeManager(this._preferences) : super(ThemeMode.light);

  final SharedPreferences _preferences;

  // Generate random strings here: http://bit.ly/random-strings-generator
  static const _prefsKey = 'yNLV1XGjsDaV';

  void initialize() {
    final isDark = _preferences.getBool(_prefsKey) ?? false;
    notifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    _preferences.setBool(_prefsKey, notifier.value != ThemeMode.dark);
    notifier.value =
        notifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  @disposeMethod // Annotated so `get_it` can dispose this properly
  @override
  void dispose() {
    super.dispose();
  }
}
