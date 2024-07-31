import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AppShimmer extends StatelessWidget {
  const AppShimmer({
    required this.child,
    required this.isLoading,
    super.key,
  });

  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isLoading,
      effect: ShimmerEffect(
        baseColor: context.colorScheme.shadow.withOpacity(0.1),
        highlightColor: context.colorScheme.shadow.withOpacity(0.04),
      ),
      textBoneBorderRadius: TextBoneBorderRadius(BorderRadius.circular(4)),
      enableSwitchAnimation: true,
      child: child,
    );
  }
}
