import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

extension ExceptionExtensions on Exception {
  AppLocalizations get _l10n {
    final context =
        GetIt.I<GoRouter>().routerDelegate.navigatorKey.currentState!.context;
    return AppLocalizations.of(context)!;
  }

  String get errorMessage {
    return switch (this) {
      final FirebaseAuthException _ => _l10n.incorrectPinError,
      final DioException _ => _l10n.dioGenericError,
      final FirebaseException e => e.message ?? _l10n.firebaseGenericError,
      _ => _l10n.longGenericError,
    };
  }
}
