import 'package:awesome_period_tracker/core/widgets/app_loader/app_loader.dart';
import 'package:flutter/material.dart';

abstract class AppLoaderDialog {
  static show(
    BuildContext context, {
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.white.withOpacity(0.8),
      barrierDismissible: barrierDismissible,
      builder: (context) => const Center(child: AppLoader()),
    );
  }

  static hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
