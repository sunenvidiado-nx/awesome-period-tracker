import 'package:awesome_period_tracker/app/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/ui/common_widgets/app_loader/app_loader.dart';
import 'package:flutter/material.dart';

abstract class AppLoaderDialog {
  static show(
    BuildContext context, {
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierColor: context.colorScheme.surfaceContainer.withAlpha(140),
      barrierDismissible: barrierDismissible,
      builder: (context) => const Center(child: AppLoader()),
    );
  }

  static hide(BuildContext context) => context.popNavigator();
}
