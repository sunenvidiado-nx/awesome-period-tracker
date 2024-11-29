import 'package:awesome_period_tracker/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class Themes {
  static ThemeData get light => _lightTheme;
  static ThemeData get dark => _darkTheme;
}

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
  error: AppColors.errorRed, // Softer red for error states
  onPrimary: AppColors.bgWhite,
  onSecondary: AppColors.black,
  onTertiary: AppColors.bgWhite,
  onSurface: AppColors.darkGrey,
  onError: Color.fromARGB(255, 43, 23, 23),
);

final _lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: _lightColorScheme.surface,
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
  textSelectionTheme: _textSelectionTheme(_lightColorScheme),
);

const _darkColorScheme = ColorScheme.dark();
final _darkTheme = ThemeData(); // TODO: Add dark theme

TextTheme _textTheme(ColorScheme colorScheme) =>
    GoogleFonts.dmSansTextTheme().apply(
      displayColor: AppColors.grey,
      bodyColor: AppColors.grey,
    );

TextTheme _primaryTextTheme(TextTheme baseTextTheme) => GoogleFonts
        .dmSansTextTheme()
    .copyWith(
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
    )
    .apply(
      displayColor: AppColors.black,
      bodyColor: AppColors.black,
    );

AppBarTheme _appBarTheme(ColorScheme colorScheme, TextTheme primaryTextTheme) =>
    AppBarTheme(
      backgroundColor: colorScheme.surface,
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
        overlayColor: WidgetStatePropertyAll(Colors.white.withOpacity(0.1)),
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
        backgroundColor: colorScheme.tertiary,
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
      fillColor: colorScheme.tertiaryContainer,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.shadow.withAlpha(30),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.shadow.withAlpha(30),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.shadow.withAlpha(30),
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.shadow.withAlpha(30),
        ),
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.shadow.withAlpha(110),
      ),
    );

TextSelectionThemeData _textSelectionTheme(ColorScheme colorScheme) =>
    TextSelectionThemeData(
      cursorColor: colorScheme.shadow.withAlpha(100),
      selectionColor: colorScheme.tertiary,
      selectionHandleColor: colorScheme.tertiary,
    );
