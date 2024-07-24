import 'package:awesome_period_tracker/core/app_colors.dart';
import 'package:awesome_period_tracker/core/providers/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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

final themesProvider = Provider((ref) => (_lightTheme, _darkTheme));

final _darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: _darkColorScheme.surfaceContainer,
  colorScheme: _darkColorScheme,
  textTheme: _textTheme(_darkColorScheme),
  primaryTextTheme: _primaryTextTheme(_textTheme(_darkColorScheme)),
  appBarTheme: _appBarTheme(
    _darkColorScheme,
    _primaryTextTheme(_textTheme(_darkColorScheme)),
  ),
  elevatedButtonTheme: _elevatedButtonTheme(
    _darkColorScheme,
    _primaryTextTheme(_textTheme(_darkColorScheme)),
  ),
  iconButtonTheme: _iconButtonTheme(_darkColorScheme),
  textButtonTheme: _textButtonTheme(_darkColorScheme),
  inputDecorationTheme:
      _inputDecorationTheme(_darkColorScheme, _textTheme(_darkColorScheme)),
);

final _lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: _lightColorScheme.surfaceContainer,
  colorScheme: _lightColorScheme,
  textTheme: _textTheme(_lightColorScheme),
  primaryTextTheme: _primaryTextTheme(_textTheme(_lightColorScheme)),
  appBarTheme: _appBarTheme(
    _lightColorScheme,
    _primaryTextTheme(_textTheme(_lightColorScheme)),
  ),
  elevatedButtonTheme: _elevatedButtonTheme(
    _lightColorScheme,
    _primaryTextTheme(_textTheme(_lightColorScheme)),
  ),
  iconButtonTheme: _iconButtonTheme(_lightColorScheme),
  textButtonTheme: _textButtonTheme(_lightColorScheme),
  inputDecorationTheme:
      _inputDecorationTheme(_lightColorScheme, _textTheme(_darkColorScheme)),
);

const _darkColorScheme = ColorScheme.dark(
  primary: AppColors.pink,
  secondary: AppColors.blue,
  secondaryContainer: AppColors.green,
  tertiary: AppColors.orange,
  error: AppColors.red,
  surface: AppColors.black,
  surfaceContainer: Colors.black,
  shadow: AppColors.white,
);

const _lightColorScheme = ColorScheme.light(
  primary: AppColors.pink,
  secondary: AppColors.blue,
  secondaryContainer: AppColors.green,
  tertiary: AppColors.orange,
  error: AppColors.red,
  surface: Colors.white,
  surfaceContainer: AppColors.white,
  shadow: Colors.black54,
);

TextTheme _textTheme(ColorScheme colorScheme) =>
    GoogleFonts.dmSansTextTheme().apply(
      displayColor: colorScheme.shadow.withAlpha(200),
      bodyColor: colorScheme.shadow.withAlpha(200),
    );

TextTheme _primaryTextTheme(TextTheme baseTextTheme) =>
    GoogleFonts.dmSansTextTheme().copyWith(
      displayLarge:
          baseTextTheme.displayLarge!.copyWith(fontWeight: FontWeight.bold),
      displayMedium:
          baseTextTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold),
      displaySmall:
          baseTextTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
      headlineLarge:
          baseTextTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold),
      headlineMedium:
          baseTextTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
      headlineSmall:
          baseTextTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
      titleLarge:
          baseTextTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
      titleMedium:
          baseTextTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
      titleSmall:
          baseTextTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
      bodyMedium:
          baseTextTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
      bodySmall: baseTextTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
      labelLarge:
          baseTextTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold),
      labelMedium:
          baseTextTheme.labelMedium!.copyWith(fontWeight: FontWeight.bold),
      labelSmall:
          baseTextTheme.labelSmall!.copyWith(fontWeight: FontWeight.bold),
    );

AppBarTheme _appBarTheme(ColorScheme colorScheme, TextTheme primaryTextTheme) =>
    AppBarTheme(
      backgroundColor: colorScheme.surfaceContainer,
      titleTextStyle: primaryTextTheme.titleLarge!.copyWith(fontSize: 16),
      elevation: 0,
      toolbarHeight: 32,
      centerTitle: true,
    );

ElevatedButtonThemeData _elevatedButtonTheme(
  ColorScheme colorScheme,
  TextTheme primaryTextTheme,
) =>
    ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: const WidgetStatePropertyAll(0),
        foregroundColor: WidgetStatePropertyAll(colorScheme.surface),
        backgroundColor: WidgetStatePropertyAll(colorScheme.primary),
        minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 48)),
        textStyle: WidgetStatePropertyAll(
          primaryTextTheme.titleMedium?.copyWith(fontSize: 16),
        ),
        fixedSize: const WidgetStatePropertyAll(Size(double.infinity, 52)),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(16)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );

IconButtonThemeData _iconButtonTheme(ColorScheme colorScheme) =>
    IconButtonThemeData(
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surfaceContainer,
        foregroundColor: colorScheme.shadow.withAlpha(200),
      ),
    );

TextButtonThemeData _textButtonTheme(ColorScheme colorScheme) =>
    TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.shadow.withAlpha(200),
        backgroundColor: colorScheme.surface,
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.shadow.withAlpha(30),
            width: 1,
          ),
        ),
      ),
    );

InputDecorationTheme _inputDecorationTheme(
  ColorScheme colorScheme,
  TextTheme textTheme,
) =>
    InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.shadow.withAlpha(30),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.shadow.withAlpha(30),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.shadow.withAlpha(30),
          width: 1,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.shadow.withAlpha(30),
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.shadow.withAlpha(30),
          width: 1,
        ),
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.shadow.withAlpha(100),
      ),
    );
