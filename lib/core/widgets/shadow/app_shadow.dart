import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';

class AppShadow extends StatelessWidget {
  const AppShadow({
    required this.child,
    this.elevation = 1,
    this.shadowColor,
    super.key,
  }) : assert(elevation <= 1.5);

  final Widget child;
  final double elevation;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor ??
                context.colorScheme.shadow.withOpacity(0.12 * elevation),
            blurRadius: 12 * elevation,
            offset: Offset(0, 4 * elevation),
          ),
        ],
      ),
      child: child,
    );
  }
}
