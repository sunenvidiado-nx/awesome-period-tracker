import 'dart:async';

import 'package:awesome_period_tracker/core/app_assets.dart';
import 'package:awesome_period_tracker/core/environment.dart';
import 'package:awesome_period_tracker/core/firebase_options.dart';
import 'package:awesome_period_tracker/core/providers/gemini_client_provider.dart';
import 'package:awesome_period_tracker/core/providers/insights_box_provider.dart';
import 'package:awesome_period_tracker/features/app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

    // Preload main icon
    const loader = SvgAssetLoader(AppAssets.mainIconNoBackground);
    svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));

    await Hive.initFlutter();

    final insightsBox = await Hive.openBox<String>('insights');

    final geminiClient = GeminiClient(
      model: GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: Environment.geminiApiKey,
      ),
    );

    runApp(
      ProviderScope(
        overrides: [
          insightsBoxProvider.overrideWithValue(insightsBox),
          geminiClientProvider.overrideWithValue(geminiClient),
        ],
        child: const App(),
      ),
    );
  });
}
