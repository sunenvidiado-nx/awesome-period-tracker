import 'package:awesome_period_tracker/core/extensions/date_time_extensions.dart';
import 'package:awesome_period_tracker/features/home/data/cycle_events_repository.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:awesome_period_tracker/features/home/domain/period_flow.dart';
import 'package:awesome_period_tracker/features/home/domain/symptoms.dart';
import 'package:awesome_period_tracker/features/pin_login/domain/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

part 'log_cycle_event_state_provider.mapper.dart';

@MappableClass()
class LogCycleEventState with LogCycleEventStateMappable {
  final CycleEventType? selectedCycleEventType;
  final Exception? error;
  final double bottomSheetHeightFactor;

  const LogCycleEventState({
    this.selectedCycleEventType,
    this.error,
    this.bottomSheetHeightFactor = 0.45,
  });
}

class LogCycleEventStateNotifier
    extends AutoDisposeNotifier<LogCycleEventState> {
  late final _now = DateTime.now();

  @override
  LogCycleEventState build() => const LogCycleEventState();

  void changeCycleEventType(CycleEventType? cycleEventType) {
    final heightFactor = switch (cycleEventType) {
      CycleEventType.period => 0.5,
      CycleEventType.symptoms => 0.7,
      _ => 0.47,
    };

    state = state.copyWith(
      selectedCycleEventType: cycleEventType,
      bottomSheetHeightFactor: heightFactor,
    );
  }

  Future<void> logPeriod(PeriodFlow flow) async {
    late CycleEvent? cycleEvent;

    cycleEvent = await ref.read(cycleEventsRepositoryProvider).get({
      'createdBy': ref.read(authRepositoryProvider).getCurrentUser()!.uid,
      'date': Timestamp.fromDate(_now.withoutTime()),
      'type': CycleEventType.period.name,
    }).then(
      (value) => value.firstWhereOrNull((e) => isSameDay(e.date, _now)),
    );

    if (cycleEvent != null) {
      cycleEvent = cycleEvent.copyWith(additionalData: flow.name);

      return await ref.read(cycleEventsRepositoryProvider).update(cycleEvent);
    }

    cycleEvent = CycleEvent(
      date: _now,
      additionalData: flow.name,
      type: CycleEventType.period,
      createdBy: ref.read(authRepositoryProvider).getCurrentUser()!.uid,
    );

    return await ref.read(cycleEventsRepositoryProvider).create(cycleEvent);
  }

  Future<void> logSymptoms(
    List<Symptoms> symptoms,
    String? addtionalInfo,
  ) async {
    late CycleEvent? cycleEvent;

    final updatedSymptoms = [
      ...symptoms.map((e) => e.title),
      if (addtionalInfo != null) addtionalInfo,
    ].join(Symptoms.separator);

    cycleEvent = await ref.read(cycleEventsRepositoryProvider).get({
      'createdBy': ref.read(authRepositoryProvider).getCurrentUser()!.uid,
      'date': Timestamp.fromDate(_now.withoutTime()),
      'type': CycleEventType.symptoms.name,
    }).then(
      (value) => value.firstWhereOrNull((e) => isSameDay(e.date, _now)),
    );

    if (cycleEvent != null) {
      cycleEvent = cycleEvent.copyWith(
        additionalData: updatedSymptoms,
      );

      return await ref.read(cycleEventsRepositoryProvider).update(cycleEvent);
    }

    cycleEvent = CycleEvent(
      date: _now,
      additionalData: updatedSymptoms,
      type: CycleEventType.symptoms,
      createdBy: ref.read(authRepositoryProvider).getCurrentUser()!.uid,
    );

    return await ref.read(cycleEventsRepositoryProvider).create(cycleEvent);
  }
}

final logCycleEventStateProvider = NotifierProvider.autoDispose<
    LogCycleEventStateNotifier, LogCycleEventState>(
  LogCycleEventStateNotifier.new,
);
