import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension BuildContextExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  TextTheme get primaryTextTheme => Theme.of(this).primaryTextTheme;

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Useful for popping Flutter dialogs.
  void popNavigator([Object? result]) => Navigator.of(this).pop(result);
}
