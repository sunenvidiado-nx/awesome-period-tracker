import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/extensions/string_extensions.dart';
import 'package:awesome_period_tracker/core/widgets/app_loader/app_shimmer.dart';
import 'package:awesome_period_tracker/core/widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/features/home/application/cycle_forecast_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InfoCards extends ConsumerWidget {
  const InfoCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cycleForecastProvider);

    return Column(
      children: [
        Row(
          children: [
            Flexible(
              child: _buildCard(
                context,
                isLoading: state.isLoading,
                iconText: context.l10n.phase,
                title: state.maybeWhen(
                  orElse: () => context.l10n.veryShortGenericError,
                  data: (forecast) => forecast.phase.name.toTitleCase(),
                ),
                subtitle: state.maybeWhen(
                  orElse: () => context.l10n.veryShortGenericError,
                  data: (forecast) => context.l10n.preparingForPhase(
                    forecast.phase.nextPhase.name,
                  ),
                ),
                icon: Icon(
                  Icons.dark_mode_rounded,
                  color: context.colorScheme.secondaryFixed,
                  size: 25,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: _buildCard(
                context,
                isLoading: state.isLoading,
                iconText: context.l10n.cycleDay,
                title: context.l10n.dayN(5),
                subtitle: context.l10n.nDaysUntilNextPeriod(26),
                icon: Icon(
                  Icons.calendar_today_rounded,
                  color: context.colorScheme.primary,
                  size: 22,
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
                isLoading: state.isLoading,
                iconText: context.l10n.fertileWindow,
                title: context.l10n.inNDays(5),
                subtitle: context.l10n.ovulationStartsOnDate('Aug 2'),
                icon: Icon(
                  Icons.adjust,
                  color: context.colorScheme.tertiary,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: _buildCard(
                context,
                isLoading: state.isLoading,
                iconText: context.l10n.intimacy,
                title: 'Got freaky',
                subtitle: context.l10n.usedProtectionYesOrNo('Yes'),
                icon: Icon(
                  Icons.favorite,
                  color: context.colorScheme.primary,
                  size: 24,
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
                Row(
                  children: [
                    isLoading ? const Icon(Icons.circle, size: 24) : icon,
                    const SizedBox(width: 8),
                    Text(
                      iconText,
                      style: context.primaryTextTheme.titleMedium,
                    ),
                  ],
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
