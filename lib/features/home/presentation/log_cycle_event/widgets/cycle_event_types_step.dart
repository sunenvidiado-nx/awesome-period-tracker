import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:awesome_period_tracker/features/home/presentation/log_cycle_event/log_cycle_event_state_provider.dart';
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
          for (final type in CycleEventType.values)
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
    // Some UI adjustments for the different cycle event types
    // have been applied by eye so it looks a little better.

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 1),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: type.color.withOpacity(
                  type == CycleEventType.intimacy ? 0.18 : 0.25,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Transform.scale(
                scale: type == CycleEventType.period
                    ? 0.55
                    : type == CycleEventType.fertile
                        ? 0.55
                        : 1.1,
                child: type.icon,
              ),
            ),
            title: Text(
              type == CycleEventType.fertile
                  ? context.l10n.fertility
                  : type.label,
              style: context.primaryTextTheme.titleMedium,
            ),
            onTap: () => ref
                .read(logCycleEventStateProvider.notifier)
                .changeCycleEventType(type),
          ),
        ),
      ),
    );
  }
}
