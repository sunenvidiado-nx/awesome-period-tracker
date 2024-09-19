import 'package:animations/animations.dart';
import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/application/log_cycle_event_state_provider.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/domain/log_event_step.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/presentation/widgets/add_new_symptom_step.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/presentation/widgets/intimacy_step.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/presentation/widgets/period_flow_step.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/presentation/widgets/symptoms_step.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogCycleEventBottomSheet extends ConsumerStatefulWidget {
  const LogCycleEventBottomSheet({
    required this.date,
    required this.step,
    required this.cycleEventsForDate,
    super.key,
  });

  final DateTime date;
  final LogEventStep step;
  final List<CycleEvent> cycleEventsForDate;

  static Future<void> showCycleEventTypeBottomSheet(
    BuildContext context, {
    required LogEventStep step,
    required DateTime date,
    required List<CycleEvent> cycleEventsForDate,
  }) async {
    await showModalBottomSheet(
      context: context,
      scrollControlDisabledMaxHeightRatio: 0.9,
      isScrollControlled: true,
      barrierColor: context.colorScheme.shadow.withOpacity(0.3),
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: LogCycleEventBottomSheet(
          date: date,
          step: step,
          cycleEventsForDate: cycleEventsForDate,
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
          .read(logCycleEventStateProvider(widget.step).notifier)
          .setDate(widget.date);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logCycleEventStateProvider(widget.step));
    final height = MediaQuery.of(context).size.height * state.heightFactor;

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
          _buildBody(context, state),
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

  Widget _buildBody(BuildContext context, LogEventStep step) {
    return Expanded(
      child: PageTransitionSwitcher(
        reverse: step != LogEventStep.addNewSymptom,
        transitionBuilder: (child, animation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            fillColor: Colors.transparent,
            child: child,
          );
        },
        child: switch (step) {
          LogEventStep.periodFlow => PeriodFlowStep(
              periodEvent: widget.cycleEventsForDate.firstWhereOrNull(
                (e) => e.type == CycleEventType.period && !e.isPrediction,
              ),
            ),
          LogEventStep.symptoms => SymptomsStep(
              symptomEvent: widget.cycleEventsForDate.firstWhereOrNull(
                (e) => e.type == CycleEventType.symptoms,
              ),
            ),
          LogEventStep.intimacy => IntimacyStep(
              intimacyEvent: widget.cycleEventsForDate.firstWhereOrNull(
                (e) => e.type == CycleEventType.intimacy && !e.isPrediction,
              ),
            ),
          LogEventStep.addNewSymptom => const AddNewSymptomStep(),
        },
      ),
    );
  }
}
