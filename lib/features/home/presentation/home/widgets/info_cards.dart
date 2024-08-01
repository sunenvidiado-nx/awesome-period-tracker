import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/extensions/date_time_extensions.dart';
import 'package:awesome_period_tracker/core/extensions/string_extensions.dart';
import 'package:awesome_period_tracker/core/widgets/app_loader/app_shimmer.dart';
import 'package:awesome_period_tracker/core/widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/features/home/application/cycle_events_for_date_provider.dart';
import 'package:awesome_period_tracker/features/home/application/cycle_forecast_provider.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class InfoCards extends ConsumerWidget {
  const InfoCards(this.date, {super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cycleForecastState =
        ref.watch(cycleForecastProvider(date.withoutTime()));
    final cycleEventsState =
        ref.watch(cycleEventsForDateProvider(date.withoutTime()));
    final isLoading =
        cycleForecastState.isLoading || cycleEventsState.isLoading;

    return Column(
      children: [
        Row(
          children: [
            Flexible(
              child: _buildCard(
                context,
                isLoading: isLoading,
                iconText: context.l10n.phase,
                title: cycleForecastState.maybeWhen(
                  orElse: () => context.l10n.veryShortGenericError,
                  data: (forecast) => forecast.phase.name.toTitleCase(),
                ),
                subtitle: cycleForecastState.maybeWhen(
                  orElse: () => context.l10n.veryShortGenericError,
                  data: (forecast) => context.l10n.preparingForPhase(
                    forecast.phase.nextPhase.name,
                  ),
                ),
                icon: Icon(
                  Icons.dark_mode_rounded,
                  color: context.colorScheme.secondaryFixed,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: _buildCard(
                context,
                isLoading: isLoading,
                iconText: context.l10n.cycleDay,
                title: context.l10n.dayN(
                  cycleForecastState.maybeWhen(
                    orElse: () => 69,
                    data: (data) => data.dayOfCycle,
                  ),
                ),
                subtitle: context.l10n.nDaysUntilNextPeriod(
                  cycleForecastState.maybeWhen(
                    orElse: () => 69,
                    data: (data) => data.daysUntilNextPeriod,
                  ),
                ),
                icon: Icon(
                  Icons.radio_button_checked,
                  color: context.colorScheme.error,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Flexible(
              child: _buildCard(
                context,
                isLoading: isLoading,
                iconText: context.l10n.intimacy,
                title: cycleEventsState.maybeWhen(
                  orElse: () => context.l10n.veryShortGenericError,
                  data: (data) =>
                      data.any((event) => event.type == CycleEventType.intimacy)
                          ? context.l10n.gotFreaky
                          : context.l10n.noFreaky,
                ),
                subtitle: cycleEventsState.maybeWhen(
                  orElse: () => context.l10n.noIntimacyLogged,
                  data: (data) =>
                      data
                          .firstWhereOrNull(
                            (event) => event.type == CycleEventType.intimacy,
                          )
                          ?.additionalData ??
                      context.l10n.noIntimacyLogged,
                ),
                icon: Icon(
                  Icons.favorite,
                  color: context.colorScheme.secondary,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: _buildCard(
                context,
                isLoading: isLoading,
                iconText: context.l10n.fertileWindow,
                title: cycleForecastState.maybeWhen(
                  orElse: () => context.l10n.veryShortGenericError,
                  data: (data) => data.daysUntilNextFertileWindow == 0
                      ? context.l10n.today
                      : context.l10n.inNDays(data.daysUntilNextFertileWindow),
                ),
                subtitle: cycleForecastState.maybeWhen(
                  orElse: () => context.l10n.veryShortGenericError,
                  data: (data) => data.daysUntilNextFertileWindow == 0
                      ? context.l10n.currentlyFertile
                      : context.l10n.ovulationStartsOnDate(
                          data.nextFertileWindowStartDate.toMonthAndDay(),
                        ),
                ),
                icon: Icon(
                  Icons.adjust,
                  color: context.colorScheme.tertiary,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    bool isLoading = false,
    required String iconText,
    required String title,
    required String subtitle,
    required Widget icon,
    double height = 120,
  }) {
    return AppCard(
      child: AppShimmer(
        isLoading: isLoading,
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton.keep(
                  child: Row(
                    children: [
                      icon,
                      const SizedBox(width: 8),
                      Text(
                        iconText,
                        style: context.primaryTextTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: context.primaryTextTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
