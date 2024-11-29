import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

@singleton
class AuthRepository {
  const AuthRepository(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  bool isLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<void> logInWithEmailAndPassword(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  bool shouldCreateUserName() {
    return _firebaseAuth.currentUser?.displayName == null ||
        _firebaseAuth.currentUser?.displayName == '';
  }

  Future<void> setUserName(String userName) async {
    await _firebaseAuth.currentUser!.updateDisplayName(userName);
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
