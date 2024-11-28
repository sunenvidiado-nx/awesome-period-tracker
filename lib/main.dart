import 'dart:async';

import 'package:awesome_period_tracker/core/app_assets.dart';
import 'package:awesome_period_tracker/core/infrastructure/dependency_injection.dart';
import 'package:awesome_period_tracker/features/app/presentation/app.dart';
import 'package:awesome_period_tracker/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runZoned(() async {
    WidgetsFlutterBinding.ensureInitialized();

    _setUpLicenses();

    await _setUpFirebase(); // Must be called before any other initialization

    await Future.wait([
      _clearCacheOnNewVersion(),
      _preloadSvgs(),
      configureDependencies(),
    ]);

    runApp(const App());
  });
}

void _setUpLicenses() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
}

Future<void> _setUpFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

Future<void> _clearCacheOnNewVersion() async {
  // Generate random strings here: http://bit.ly/random-strings-generator
  const key = 'tnULfB0HpgDR';
  final prefs = await SharedPreferences.getInstance();
  final pInfo = await PackageInfo.fromPlatform();

  if (pInfo.version != prefs.getString(key)) {
    await prefs.clear();
    await prefs.setString(key, pInfo.version);
  }
}

Future<void> _preloadSvgs() async {
  const mainIconLoader = SvgAssetLoader(AppAssets.mainIcon);
  const mainIconLongLoader = SvgAssetLoader(AppAssets.mainIconLong);
  const googleGeminiIconLoader = SvgAssetLoader(AppAssets.googleGeminiIcon);

  await Future.wait([
    svg.cache.putIfAbsent(
      mainIconLoader.cacheKey(null),
      () => mainIconLoader.loadBytes(null),
    ),
    svg.cache.putIfAbsent(
      mainIconLongLoader.cacheKey(null),
      () => mainIconLongLoader.loadBytes(null),
    ),
    svg.cache.putIfAbsent(
      googleGeminiIconLoader.cacheKey(null),
      () => googleGeminiIconLoader.loadBytes(null),
    ),
  ]);
}
