import 'package:awesome_period_tracker/core/environment.dart';
import 'package:awesome_period_tracker/core/providers/firebase_auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthRepository {
  const AuthRepository(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  bool isLoggedIn() => _firebaseAuth.currentUser != null;

  User? getCurrentUser() => _firebaseAuth.currentUser;

  Future<void> pinLogin(String pin) async {
    /// I know. This seems dumb. But it still works, it's pretty secure, and me and
    /// my SO are the only users of this app. So, I'm not too worried about it. :)
    final res = await _firebaseAuth.signInWithEmailAndPassword(
      email: Environment.loginEmail,
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

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider));
});
