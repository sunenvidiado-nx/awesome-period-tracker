import 'package:awesome_period_tracker/core/extensions/date_time_extensions.dart';
import 'package:awesome_period_tracker/features/home/data/cycle_events_repository.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:awesome_period_tracker/features/home/domain/period_flow.dart';
import 'package:awesome_period_tracker/features/home/presentation/log_cycle_event/log_cycle_event_state.dart';
import 'package:awesome_period_tracker/features/pin_login/domain/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

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
    late CycleEvent? cycleEvent;

    cycleEvent = await ref.read(cycleEventsRepositoryProvider).get({
      'createdBy': ref.read(authRepositoryProvider).getCurrentUser()!.uid,
      'date': Timestamp.fromDate(state.selectedDate.withoutTime()),
      'type': CycleEventType.period.name,
    }).then(
      (value) => value.firstWhereOrNull(
        (e) =>
            isSameDay(e.date, state.selectedDate) &&
            e.type == CycleEventType.period,
      ),
    );

    if (cycleEvent != null) {
      cycleEvent = cycleEvent.copyWith(
        additionalData: flow.name,
        type: CycleEventType.period,
      );

      return await ref.read(cycleEventsRepositoryProvider).update(cycleEvent);
    }

    cycleEvent = CycleEvent(
      date: state.selectedDate,
      additionalData: flow.name,
      type: CycleEventType.period,
      createdBy: ref.read(authRepositoryProvider).getCurrentUser()!.uid,
    );

    return await ref.read(cycleEventsRepositoryProvider).create(cycleEvent);
  }
}

final logCycleEventStateProvider = NotifierProvider.autoDispose<
    LogCycleEventStateNotifier, LogCycleEventState>(
  LogCycleEventStateNotifier.new,
);
