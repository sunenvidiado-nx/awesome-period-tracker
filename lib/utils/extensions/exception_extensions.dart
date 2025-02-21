import 'package:awesome_period_tracker/utils/extensions/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

extension ExceptionExtensions on Exception {
  String get errorMessage {
    return switch (this) {
      final FirebaseAuthException _ => l10n.incorrectPinError,
      final DioException _ => l10n.dioGenericError,
      final FirebaseException e => e.message ?? l10n.firebaseGenericError,
      _ => l10n.longGenericError,
    };
  }
}
