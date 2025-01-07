import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:very_simple_state_manager/very_simple_state_manager.dart';

@singleton
class ThemeModeManager extends StateManager<ThemeMode> {
  ThemeModeManager(this._secureStorage) : super(ThemeMode.light);

  final FlutterSecureStorage _secureStorage;

  // Generate random strings here: http://bit.ly/random-strings-generator
  static const _prefsKey = 'yNLV1XGjsDaV';

  Future<void> initialize() async {
    final isDarkStr = await _secureStorage.read(key: _prefsKey);
    final isDark = isDarkStr == 'true';
    notifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final newIsDark = notifier.value != ThemeMode.dark;
    await _secureStorage.write(key: _prefsKey, value: newIsDark.toString());
    notifier.value = newIsDark ? ThemeMode.dark : ThemeMode.light;
  }

  @disposeMethod // Annotated so `get_it` can dispose this properly
  @override
  void dispose() {
    super.dispose();
  }
}
