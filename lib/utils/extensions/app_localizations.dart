import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

/// A getter that provides access to localized strings through [AppLocalizations].
///
/// This getter retrieves the current [BuildContext] from the global [GoRouter]
/// instance and uses it to access the appropriate [AppLocalizations] instance.
AppLocalizations get l10n {
  final context =
      GetIt.I<GoRouter>().routerDelegate.navigatorKey.currentContext!;
  return AppLocalizations.of(context)!;
}
