import 'package:awesome_period_tracker/features/home/data/cycle_events_repository.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:awesome_period_tracker/features/home/domain/period_flow.dart';
import 'package:awesome_period_tracker/features/home/presentation/log_cycle_event/log_cycle_event_state.dart';
import 'package:awesome_period_tracker/features/pin_login/domain/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogCycleEventStateNotifier
    extends AutoDisposeNotifier<LogCycleEventState> {
  @override
  LogCycleEventState build() {
    return LogCycleEventState(
      selectedDate: DateTime.now(),
    );
  }

  void changeCycleEventType(CycleEventType? cycleEventType) {
    state = state.copyWith(selectedCycleEventType: cycleEventType);
  }

  void changeDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  Future<void> logPeriod(PeriodFlow flow) async {
    final cycleEvent = CycleEvent(
      date: state.selectedDate,
      type: CycleEventType.period,
      createdBy: ref.read(authRepositoryProvider).getCurrentUser()!.uid,
      additionalData: flow.name,
    );

    await ref.read(cycleEventsRepositoryProvider).addCycleEvent(cycleEvent);
  }
}

final logCycleEventStateProvider = NotifierProvider.autoDispose<
    LogCycleEventStateNotifier, LogCycleEventState>(
  LogCycleEventStateNotifier.new,
);
