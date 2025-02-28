import 'package:awesome_period_tracker/config/constants/ui_constants.dart';
import 'package:awesome_period_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  TextTheme get primaryTextTheme => Theme.of(this).primaryTextTheme;

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Useful for popping Flutter dialogs.
  void popNavigator([Object? result]) => Navigator.of(this).pop(result);

  bool get isDesktop => MediaQuery.of(this).size.width > UiConstants.mobileWidth;
}
