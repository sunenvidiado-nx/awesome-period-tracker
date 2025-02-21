import 'dart:async';

import 'package:awesome_period_tracker/app/app.dart';
import 'package:awesome_period_tracker/app/theme/app_colors.dart';
import 'package:awesome_period_tracker/config/di_setup.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  runZoned(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await configureDependencies();

    _configureCrashlytics();
    _configureLicenses();
    _configureTimezonePlugin();

    await Future.wait([
      _configureNavigationAndStatusBarColors(),
      _configureLocalStorage(),
      _configureLocalNotifications(),
    ]);

    runApp(const App());
  });
}

Future<void> _configureNavigationAndStatusBarColors() async {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.bgPalePink.withValues(alpha: 1),
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

void _configureCrashlytics() {
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

Future<void> _configureLocalStorage() async {
  // Generate cache key here: http://bit.ly/random-strings-generator
  const key = 'tnULfB0HpgDR';
  final secureStorage = GetIt.I<FlutterSecureStorage>();
  final pInfo = await PackageInfo.fromPlatform();

  /// Clear local storage if the app version has changed
  if (pInfo.version != await secureStorage.read(key: key)) {
    await secureStorage.deleteAll();
    await secureStorage.write(key: key, value: pInfo.version);
  }
}

Future<void> _configureLocalNotifications() async {
  await GetIt.I<FlutterLocalNotificationsPlugin>().initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );
}

void _configureTimezonePlugin() {
  tz.initializeTimeZones();
}
