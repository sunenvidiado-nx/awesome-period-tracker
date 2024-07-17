import 'package:firebase_auth/firebase_auth.dart';

extension ExceptionExtensions on Exception {
  String get errorMessage {
    return switch (this) {
      final Exception exception when exception is FirebaseAuthException =>
        'Incorrect PIN.',
      final Exception exception when exception is FirebaseException =>
        exception.message ?? 'An error occurred. Please try again later.',
      _ => toString().split('Exception: ')[1],
    };
  }
}
