import 'package:awesome_period_tracker/features/app/router.dart';
import 'package:awesome_period_tracker/features/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routerConfig = ref.read(routerProvider);
    final theme = ref.read(themeProvider);

    return MaterialApp.router(
      title: 'Awesome Period Tracker',
      debugShowCheckedModeBanner: false,
      routerConfig: routerConfig,
      theme: theme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        return KeyboardDismissOnTap(
          dismissOnCapturedTaps: true,
          child: AnnotatedRegion(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarColor: theme.colorScheme.surfaceContainer,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            child: child!,
          ),
        );
      },
    );
  }
}
