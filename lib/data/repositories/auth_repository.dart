import 'package:awesome_period_tracker/config/environment/env.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@singleton
class AuthRepository {
  const AuthRepository(
    this._firebaseAuth,
    this._secureStorage,
    this._env,
  );

  final FirebaseAuth _firebaseAuth;
  final FlutterSecureStorage _secureStorage;
  final Env _env;

  bool isLoggedIn() => _firebaseAuth.currentUser != null;

  User? getCurrentUser() => _firebaseAuth.currentUser;

  Future<void> clearUserCache() async => _secureStorage.deleteAll();

  Future<void> pinLogin(String pin) async {
    /// I know. This seems dumb. But it still works, it's pretty secure, and me and
    /// my SO are the only users of this app. So, I'm not too worried about it. :D
    final res = await _firebaseAuth.signInWithEmailAndPassword(
      email: _env.loginEmail,
      password: pin,
    );

    if (res.user == null) {
      throw Exception('Invalid PIN');
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}