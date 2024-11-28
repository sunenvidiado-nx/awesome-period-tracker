import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/features/app/application/theme_mode_manager.dart';
import 'package:awesome_period_tracker/features/app/application/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = GetIt.I<ThemeModeManager>().notifier.value;

    return MaterialApp.router(
      title: 'Awesome Period Tracker',
      debugShowCheckedModeBanner: false,
      routerConfig: GetIt.I<GoRouter>(),
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        return KeyboardDismissOnTap(
          dismissOnCapturedTaps: true,
          child: AnnotatedRegion(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: themeMode == ThemeMode.dark
                  ? Brightness.light
                  : Brightness.dark,
              systemNavigationBarColor: context.colorScheme.surface,
              systemNavigationBarIconBrightness: themeMode == ThemeMode.dark
                  ? Brightness.light
                  : Brightness.dark,
            ),
            child: child!,
          ),
        );
      },
    );
  }
}
