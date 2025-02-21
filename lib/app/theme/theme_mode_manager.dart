import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@singleton
class ThemeModeCubit extends Cubit<ThemeMode> {
  ThemeModeCubit(this._secureStorage) : super(ThemeMode.light);

  final FlutterSecureStorage _secureStorage;

  // Generate random strings here: http://bit.ly/random-strings-generator
  static const _prefsKey = 'yNLV1XGjsDaV';

  Future<void> initialize() async {
    final isDarkStr = await _secureStorage.read(key: _prefsKey);
    final isDark = isDarkStr == 'true';
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleTheme() async {
    final newIsDark = state != ThemeMode.dark;
    await _secureStorage.write(key: _prefsKey, value: newIsDark.toString());
    emit(newIsDark ? ThemeMode.dark : ThemeMode.light);
  }

  @disposeMethod // Annotated so `get_it` can dispose this properly
  @override
  Future<void> close() async => super.close();
}
