import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/extensions/date_time_extensions.dart';
import 'package:awesome_period_tracker/core/extensions/string_extensions.dart';
import 'package:awesome_period_tracker/core/widgets/app_loader/app_shimmer.dart';
import 'package:awesome_period_tracker/core/widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/features/home/application/cycle_events_for_date_provider.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:awesome_period_tracker/features/home/domain/symptoms.dart';
import 'package:awesome_period_tracker/features/home/presentation/log_cycle_event/log_cycle_event_bottom_sheet.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SymptomsSection extends ConsumerWidget {
  const SymptomsSection(this.date, {super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cycleEventsForDateProvider(date.withoutTime()));

    return AppCard(
      isAnimated: true,
      child: InkWell(
        onTap: () => LogCycleEventBottomSheet.showCycleEventTypeBottomSheet(
          context,
          eventType: CycleEventType.symptoms,
          date: date,
        ),
        child: AppShimmer(
          isLoading: state.isLoading || state.isRefreshing || state.isReloading,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton.keep(
                    child: Row(
                      children: [
                        Icon(
                          Icons.emergency,
                          size: 20,
                          color: context.colorScheme.shadow.withOpacity(0.4),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.symptoms,
                          style: context.primaryTextTheme.titleMedium,
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.add_rounded,
                          size: 20,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  state.maybeWhen(
                    loading: () =>
                        _buildChips(context, const ['one', 'one two', 'three']),
                    data: (cycleEvents) =>
                        _buildSymptomsList(context, cycleEvents),
                    orElse: () => _buildNoSymptomsPlaceholder(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSymptomsList(
    BuildContext context,
    List<CycleEvent> events,
  ) {
    final symptomsEvent =
        events.firstWhereOrNull((e) => e.type == CycleEventType.symptoms);

    if (symptomsEvent == null) return _buildNoSymptomsPlaceholder(context);

    final symptoms = symptomsEvent.additionalData!
        .split(Symptoms.separator)
        .map((e) => e.toTitleCase())
        .toList();

    return _buildChips(context, symptoms);
  }

  Widget _buildChips(BuildContext context, List<String> labels) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final label in labels)
            Skeleton.leaf(
              child: Chip(
                label: Text(label),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                side: BorderSide(
                  color: context.colorScheme.onSurface.withOpacity(0.2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoSymptomsPlaceholder(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Center(
        child: Text(
          context.l10n.noSymptomsLogged,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
