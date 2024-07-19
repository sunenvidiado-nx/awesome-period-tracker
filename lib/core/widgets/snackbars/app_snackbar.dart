import 'package:flutter/material.dart';

abstract class AppSnackbar {
  static show(BuildContext context, {required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

extension AppSnackbarExtension on BuildContext {
  void showSnackbar(String message) {
    AppSnackbar.show(this, message: message);
  }
}
