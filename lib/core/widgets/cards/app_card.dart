import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.backgroundColor,
    this.boxShadow,
    this.border,
    super.key,
  });

  final Widget child;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: border ??
            Border.all(
              color: context.colorScheme.shadow.withAlpha(30),
              width: 1,
            ),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}
