import 'dart:async';

import 'package:awesome_period_tracker/app/app.dart';
import 'package:awesome_period_tracker/config/dependency_injection.dart';
import 'package:awesome_period_tracker/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  runZoned(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await _configureFirebase(); // Must be called before any other initialization

    configureDependencies();
    _configureLicenses();

    await Future.wait([
      _configureNavigationAndStatusBarColors(),
      _configureLocalStorage(),
    ]);

    runApp(const App());
  });
}

Future<void> _configureNavigationAndStatusBarColors() async {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black.withValues(alpha: 1),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}

void _configureLicenses() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
}

Future<void> _configureFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

/// Clear local storage if the app version has changed
Future<void> _configureLocalStorage() async {
  // Generate cache key here: http://bit.ly/random-strings-generator
  const key = 'tnULfB0HpgDR';
  final secureStorage = GetIt.I<FlutterSecureStorage>();
  final pInfo = await PackageInfo.fromPlatform();

  if (pInfo.version != await secureStorage.read(key: key)) {
    await secureStorage.deleteAll();
    await secureStorage.write(key: key, value: pInfo.version);
  }
}
