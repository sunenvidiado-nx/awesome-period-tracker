import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/extensions/date_time_extensions.dart';
import 'package:awesome_period_tracker/features/home/data/insights_repository.dart';
import 'package:awesome_period_tracker/features/home/presentation/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

final _now = DateTime.now();

final _insightProvider =
    FutureProvider.family.autoDispose((ref, DateTime selectedDate) async {
  final predictions = await ref.watch(cyclePredictionsProvider.future);

  return ref
      .read(insightsRepositoryProvider)
      .getInsightForDate(selectedDate, predictions);
});

class Insights extends ConsumerWidget {
  const Insights({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_insightProvider(_now));

    return Skeletonizer(
      key: ValueKey(state.toString() + _now.toString()),
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
              data: (insight) => insight.dayOfCycle,
            ),
            style: context.primaryTextTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            state.maybeWhen(
              orElse: () => 'Lorem ipsum dolor sit amet consectetur',
              data: (insight) =>
                  '${_now.toReadableString()} - ${insight.daysUntilNextPeriod}',
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
