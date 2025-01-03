import 'package:awesome_period_tracker/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppThemes {
  static ThemeData get light => _lightTheme;
  static ThemeData get dark => _darkTheme;
}

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

const _lightColorScheme = ColorScheme.light(
  primary: AppColors.red,
  primaryContainer: AppColors.bgPalePink,
  secondary: AppColors.pink,
  secondaryContainer: AppColors.bgPaleBlue,
  secondaryFixed: AppColors.orange,
  tertiary: AppColors.purple,
  tertiaryContainer: AppColors.bgLightGray,
  surface: AppColors.bgWhite,
  surfaceContainer: AppColors.bgPalePink,
  error: Color(0xFFF66279),
  onPrimary: AppColors.bgWhite,
  onSecondary: AppColors.outline,
  onTertiary: AppColors.bgWhite,
  onSurface: AppColors.outline,
  onError: Color.fromARGB(255, 43, 23, 23),
);

final _darkColorScheme = ColorScheme.dark(
  primary: AppColors.red.withAlpha(204),
  primaryContainer: AppColors.red.withAlpha(51),
  secondary: AppColors.pink.withAlpha(204),
  secondaryContainer: AppColors.pink.withAlpha(51),
  secondaryFixed: AppColors.orange.withAlpha(204),
  tertiary: AppColors.purple.withAlpha(204),
  tertiaryContainer: AppColors.purple.withAlpha(51),
  surface: const Color(0xFF121212),
  error: const Color(0xFFCF6679),
  onPrimary: AppColors.bgWhite,
  onSecondary: AppColors.outline,
  onTertiary: AppColors.bgWhite,
  onSurface: AppColors.bgWhite,
  onError: AppColors.outline,
);

TextTheme _textTheme(ColorScheme colorScheme) =>
    GoogleFonts.dmSansTextTheme().apply(
      displayColor: colorScheme.shadow,
      bodyColor: colorScheme.shadow,
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
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: primaryTextTheme.titleLarge,
    );

ElevatedButtonThemeData _elevatedButtonTheme(
  ColorScheme colorScheme,
  TextTheme primaryTextTheme,
) =>
    ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.primary.withAlpha(31);
          }
          return colorScheme.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withAlpha(31);
          }
          return colorScheme.onPrimary;
        }),
        elevation: WidgetStateProperty.all(0),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        textStyle: WidgetStateProperty.all(primaryTextTheme.labelLarge),
      ),
    );

IconButtonThemeData _iconButtonTheme(ColorScheme colorScheme) =>
    IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(colorScheme.primary),
        overlayColor: WidgetStateProperty.all(
          colorScheme.primary.withAlpha(31),
        ),
      ),
    );

TextButtonThemeData _textButtonTheme(ColorScheme colorScheme) =>
    TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withAlpha(31);
          }
          return colorScheme.primary;
        }),
        overlayColor: WidgetStateProperty.all(
          colorScheme.primary.withAlpha(31),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    );

InputDecorationTheme _inputDecorationTheme(
  ColorScheme colorScheme,
  TextTheme textTheme,
) =>
    InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainer,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 2,
        ),
      ),
      labelStyle: textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface.withAlpha(153),
      ),
      floatingLabelStyle: textTheme.bodyLarge?.copyWith(
        color: colorScheme.primary,
      ),
      errorStyle: textTheme.bodySmall?.copyWith(
        color: colorScheme.error,
      ),
      suffixIconColor: colorScheme.onSurface.withAlpha(153),
    );
