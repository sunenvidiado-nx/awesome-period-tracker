import 'dart:async';

import 'package:awesome_period_tracker/core/app_assets.dart';
import 'package:awesome_period_tracker/core/firebase_options.dart';
import 'package:awesome_period_tracker/core/providers/shared_preferences_provider.dart';
import 'package:awesome_period_tracker/features/app/presentation/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runZoned(() async {
    WidgetsFlutterBinding.ensureInitialized();

    LicenseRegistry.addLicense(() async* {
      final license = await rootBundle.loadString('google_fonts/OFL.txt');
      yield LicenseEntryWithLineBreaks(['google_fonts'], license);
    });

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Preload SVGs
    const mainIconLoader = SvgAssetLoader(AppAssets.mainIcon);
    const mainIconLongLoader = SvgAssetLoader(AppAssets.mainIconLong);
    const googleGeminiIconLoader = SvgAssetLoader(AppAssets.googleGeminiIcon);

    svg.cache
      ..putIfAbsent(
        mainIconLoader.cacheKey(null),
        () => mainIconLoader.loadBytes(null),
      )
      ..putIfAbsent(
        mainIconLongLoader.cacheKey(null),
        () => mainIconLongLoader.loadBytes(null),
      )
      ..putIfAbsent(
        googleGeminiIconLoader.cacheKey(null),
        () => googleGeminiIconLoader.loadBytes(null),
      );

    final shredPreferences = await SharedPreferences.getInstance();

    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(shredPreferences),
        ],
        child: const App(),
      ),
    );
  });
}
