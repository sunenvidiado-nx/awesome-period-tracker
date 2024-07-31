import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/features/home/application/log_cycle_event_state_provider.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CycleEventTypesStep extends ConsumerWidget {
  const CycleEventTypesStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.whatWouldYouLikeToLog,
            style: context.primaryTextTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          for (final type in CycleEventType.values
              .where((type) => type != CycleEventType.fertile))
            _buildCycleEventTypeTile(context, ref, type),
        ],
      ),
    );
  }

  Widget _buildCycleEventTypeTile(
    BuildContext context,
    WidgetRef ref,
    CycleEventType type,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        child: InkWell(
          onTap: () => ref
              .read(logCycleEventStateProvider.notifier)
              .changeCycleEventType(type),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                type.icon,
                const SizedBox(width: 10),
                Text(
                  type == CycleEventType.fertile
                      ? context.l10n.fertility
                      : type.label,
                  style: context.primaryTextTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
