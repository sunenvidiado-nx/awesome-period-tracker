import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dependency_injection.config.dart';

@InjectableInit()
Future<void> configureDependencies() async => await GetIt.I.init();

@module
abstract class ModuleRegister {
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get sharedPreferences async =>
      SharedPreferences.getInstance();

  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firebaseFirestore => FirebaseFirestore.instance;
}
