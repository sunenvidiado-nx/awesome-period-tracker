import 'package:awesome_period_tracker/config/environment/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'di_setup.config.dart';

@InjectableInit()
Future<void> configureDependencies() async => GetIt.I.init();

@module
abstract class ExternalServicesModule {
  @singleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

  @singleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @singleton
  FirebaseFirestore get firebaseFirestore => FirebaseFirestore.instance;

  @singleton
  FlutterLocalNotificationsPlugin get localNotificationsPlugin =>
      FlutterLocalNotificationsPlugin();

  @preResolve
  Future<FirebaseApp> get firebaseApp async =>
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
