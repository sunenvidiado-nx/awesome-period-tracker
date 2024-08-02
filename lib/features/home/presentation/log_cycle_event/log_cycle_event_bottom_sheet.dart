import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/features/home/application/log_cycle_event_state_provider.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:awesome_period_tracker/features/home/presentation/log_cycle_event/widgets/intimacy_step.dart';
import 'package:awesome_period_tracker/features/home/presentation/log_cycle_event/widgets/period_flow_step.dart';
import 'package:awesome_period_tracker/features/home/presentation/log_cycle_event/widgets/symptoms_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogCycleEventBottomSheet extends ConsumerStatefulWidget {
  const LogCycleEventBottomSheet({
    required this.eventType,
    required this.date,
    super.key,
  });

  final CycleEventType eventType;
  final DateTime date;

  static Future<void> showCycleEventTypeBottomSheet(
    BuildContext context, {
    required CycleEventType eventType,
    required DateTime date,
  }) async {
    await showModalBottomSheet(
      context: context,
      scrollControlDisabledMaxHeightRatio: 0.9,
      isScrollControlled: true,
      barrierColor: context.colorScheme.shadow.withOpacity(0.3),
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: LogCycleEventBottomSheet(
          eventType: eventType,
          date: date,
        ),
      ),
    );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LogCycleEventBottomSheetState();
}

class _LogCycleEventBottomSheetState
    extends ConsumerState<LogCycleEventBottomSheet> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(logCycleEventStateProvider(widget.eventType).notifier)
          .setDate(widget.date);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logCycleEventStateProvider(widget.eventType));
    final height =
        MediaQuery.of(context).size.height * state.bottomSheetHeightFactor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: height,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPill(context),
          Expanded(
            child: switch (state.selectedCycleEventType) {
              CycleEventType.period => const PeriodFlowStep(),
              CycleEventType.symptoms => const SymptomsStep(),
              CycleEventType.intimacy => const IntimacyStep(),
              _ => const SizedBox.shrink(),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPill(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: context.colorScheme.shadow.withAlpha(30),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
