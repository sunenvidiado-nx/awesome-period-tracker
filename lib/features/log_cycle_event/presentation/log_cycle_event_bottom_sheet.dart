import 'package:animations/animations.dart';
import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/application/log_cycle_event_state_manager.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/domain/log_event_step.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/presentation/widgets/add_new_symptom_step.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/presentation/widgets/intimacy_step.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/presentation/widgets/period_flow_step.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/presentation/widgets/symptoms_step.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LogCycleEventBottomSheet extends StatefulWidget {
  const LogCycleEventBottomSheet({
    required this.date,
    required this.step,
    required this.cycleEventsForDate,
    super.key,
  });

  final DateTime date;
  final LogEventStep step;
  final List<CycleEvent> cycleEventsForDate;

  static Future<T?> showCycleEventTypeBottomSheet<T>(
    BuildContext context, {
    required LogEventStep step,
    required DateTime date,
    required List<CycleEvent> cycleEventsForDate,
  }) async {
    return showModalBottomSheet<T?>(
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
  State<StatefulWidget> createState() => _LogCycleEventBottomSheetState();
}

class _LogCycleEventBottomSheetState extends State<LogCycleEventBottomSheet> {
  final _stateManager = GetIt.I<LogCycleEventStateManager>();

  @override
  void initState() {
    super.initState();

    _stateManager
      ..setDate(widget.date)
      ..setStep(widget.step);
  }

  @override
  void dispose() {
    _stateManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _stateManager.notifier,
      builder: (context, state, _) {
        final height =
            MediaQuery.of(context).size.height * state.step.heightFactor;

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
              _buildPill(),
              _buildBody(state.step),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPill() {
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

  Widget _buildBody(LogEventStep step) {
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
              stateManager: _stateManager,
              periodEvent: widget.cycleEventsForDate.firstWhereOrNull(
                (e) => e.type == CycleEventType.period && !e.isPrediction,
              ),
            ),
          LogEventStep.symptoms => SymptomsStep(
              stateManager: _stateManager,
              symptomEvent: widget.cycleEventsForDate.firstWhereOrNull(
                (e) => e.type == CycleEventType.symptoms,
              ),
            ),
          LogEventStep.intimacy => IntimacyStep(
              stateManager: _stateManager,
              intimacyEvent: widget.cycleEventsForDate.firstWhereOrNull(
                (e) => e.type == CycleEventType.intimacy && !e.isPrediction,
              ),
            ),
          LogEventStep.addNewSymptom =>
            AddNewSymptomStep(stateManager: _stateManager),
        },
      ),
    );
  }
}
