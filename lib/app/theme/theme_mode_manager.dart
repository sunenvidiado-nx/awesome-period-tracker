import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@singleton
class ThemeModeCubit extends Cubit<ThemeMode> {
  ThemeModeCubit(this._localStorage) : super(ThemeMode.light);

  final SharedPreferencesAsync _localStorage;

  // Generate random strings here: http://bit.ly/random-strings-generator
  static const _prefsKey = 'yNLV1XGjsDaV';

  Future<void> initialize() async {
    final isDark = await _localStorage.getBool(_prefsKey) ?? false;
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleTheme() async {
    final newIsDark = state != ThemeMode.dark;
    await _localStorage.setBool(_prefsKey, newIsDark);
    emit(newIsDark ? ThemeMode.dark : ThemeMode.light);
  }

  @disposeMethod // Annotated so `get_it` can dispose this properly
  @override
  Future<void> close() async => super.close();
}
