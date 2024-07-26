import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/features/home/application/insights_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

// Placed outside so it doesn't get rebuilt on every render
final _insightsProviderParams = InsightsProviderParams(date: DateTime.now());

class Insights extends ConsumerWidget {
  const Insights({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(insightsProvider(_insightsProviderParams));

    return Skeletonizer(
      key: ValueKey(state.toString() + _insightsProviderParams.date.toString()),
      enabled: state.isLoading || state.isReloading || state.isRefreshing,
      effect: ShimmerEffect(
        baseColor: context.colorScheme.shadow.withOpacity(0.1),
        highlightColor: context.colorScheme.shadow.withOpacity(0.04),
      ),
      textBoneBorderRadius: TextBoneBorderRadius(BorderRadius.circular(4)),
      enableSwitchAnimation: true,
      child: Column(
        key: const Key('insights'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.maybeWhen(
              orElse: () => 'Lorem ipsum dolor',
              data: (insight) => insight.dayOfCycleMessage,
            ),
            style: context.primaryTextTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            state.maybeWhen(
              orElse: () => 'Lorem ipsum dolor sit amet consectetur',
              data: (insight) => insight.daysUntilNextPeriodMessage,
            ),
            style: context.primaryTextTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            state.maybeWhen(
              orElse: () =>
                  'Cool fun insights here. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec nec odio vitae nunc ultricies lacinia. Donec nec odio vitae nunc.',
              data: (insight) => insight.insights,
            ),
            style: context.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
