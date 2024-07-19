import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/extensions/date_time_extensions.dart';
import 'package:awesome_period_tracker/features/home/data/insights_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

final _insightProvider =
    FutureProvider.family.autoDispose((ref, DateTime selectedDate) async {
  return ref.read(insightsRepositoryProvider).getInsightForDate(selectedDate);
});

class Insights extends ConsumerWidget {
  const Insights({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now().withoutTime();
    final state = ref.watch(_insightProvider(now));

    return Skeletonizer(
      key: ValueKey(state.toString() + now.toString()),
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
              orElse: () => 'Lorem ipsum dolor sit',
              data: (insight) => insight.dayOfCycle,
            ),
            style: context.primaryTextTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            state.maybeWhen(
              orElse: () => 'Lorem ipsum dolor sit amet',
              data: (insight) =>
                  '${now.toReadableString()} - ${insight.daysUntilNextPeriod}',
            ),
            style: context.primaryTextTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            state.maybeWhen(
              orElse: () =>
                  'Cool fun insights here. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec nec odio vitae nunc.',
              data: (insight) => insight.insights,
            ),
            style: context.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
