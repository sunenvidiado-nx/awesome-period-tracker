import 'package:awesome_period_tracker/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final themeProvider = Provider((ref) {
  return _lightTheme;
});

final _lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: _colorScheme.surfaceContainer,
  colorScheme: _colorScheme,
  textTheme: _textTheme,
  primaryTextTheme: _primaryTextTheme,
  appBarTheme: _appBarTheme,
  elevatedButtonTheme: _elevatedButtonTheme,
  iconButtonTheme: _iconButtonTheme,
  textButtonTheme: _textButtonTheme,
  checkboxTheme: _checkboxTheme,
);

const _colorScheme = ColorScheme.light(
  primary: AppColors.pink,
  secondary: AppColors.blue,
  secondaryContainer: AppColors.green,
  tertiary: AppColors.orange,
  error: AppColors.red,
  surface: Colors.white,
  surfaceContainer: AppColors.white,
  shadow: Colors.black54,
);

final _textTheme = GoogleFonts.dmSansTextTheme().apply(
  displayColor: _colorScheme.shadow.withAlpha(200),
  bodyColor: _colorScheme.shadow.withAlpha(200),
);

final _primaryTextTheme = GoogleFonts.dmSansTextTheme().copyWith(
  displayLarge: _textTheme.displayLarge!.copyWith(fontWeight: FontWeight.bold),
  displayMedium:
      _textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold),
  displaySmall: _textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
  headlineLarge:
      _textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold),
  headlineMedium:
      _textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
  headlineSmall:
      _textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
  titleLarge: _textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
  titleMedium: _textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
  titleSmall: _textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
  bodyLarge: _textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
  bodyMedium: _textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
  bodySmall: _textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
  labelLarge: _textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold),
  labelMedium: _textTheme.labelMedium!.copyWith(fontWeight: FontWeight.bold),
  labelSmall: _textTheme.labelSmall!.copyWith(fontWeight: FontWeight.bold),
);

final _appBarTheme = AppBarTheme(
  backgroundColor: _colorScheme.surfaceContainer,
  titleTextStyle: _primaryTextTheme.titleLarge!.copyWith(fontSize: 16),
  elevation: 0,
  toolbarHeight: 32,
  centerTitle: true,
);

final _elevatedButtonTheme = ElevatedButtonThemeData(
  style: ButtonStyle(
    elevation: const WidgetStatePropertyAll(0),
    foregroundColor: WidgetStatePropertyAll(_colorScheme.surface),
    backgroundColor: WidgetStatePropertyAll(_colorScheme.primary),
    textStyle: WidgetStatePropertyAll(
      _primaryTextTheme.titleMedium?.copyWith(fontSize: 16),
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

final _iconButtonTheme = IconButtonThemeData(
  style: IconButton.styleFrom(
    backgroundColor: _colorScheme.surfaceContainer,
    foregroundColor: _colorScheme.shadow.withAlpha(200),
  ),
);

final _textButtonTheme = TextButtonThemeData(
  style: TextButton.styleFrom(
    foregroundColor: _colorScheme.shadow.withAlpha(200),
    backgroundColor: _colorScheme.surface,
    padding: const EdgeInsets.all(8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: _colorScheme.shadow.withAlpha(30),
        width: 1,
      ),
    ),
  ),
);

final _checkboxTheme = CheckboxThemeData(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
);
