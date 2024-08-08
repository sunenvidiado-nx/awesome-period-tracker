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
  final CycleEventType selectedCycleEventType;
  final Exception? error;
  final double bottomSheetHeightFactor;

  const LogCycleEventState({
    required this.selectedCycleEventType,
    this.error,
    this.bottomSheetHeightFactor = 0.45,
  });
}

class LogCycleEventStateNotifier
    extends FamilyNotifier<LogCycleEventState, CycleEventType> {
  late DateTime _date;

  @override
  LogCycleEventState build(CycleEventType arg) {
    return LogCycleEventState(
      selectedCycleEventType: arg,
      bottomSheetHeightFactor: switch (arg) {
        CycleEventType.period => 0.55,
        CycleEventType.symptoms => 0.8,
        _ => 0.47,
      },
    );
  }

  void setDate(DateTime date) {
    _date = date;
  }

  Future<void> logPeriod(PeriodFlow flow) async {
    await _createOrUpdateEventByType(CycleEventType.period, flow.name);
  }

  Future<void> logSymptoms(
    List<Symptoms> symptoms,
    String? addtionalInfo,
  ) async {
    final updatedSymptoms = [
      ...symptoms.map((e) => e.title),
      if (addtionalInfo != null) addtionalInfo,
    ].join(Symptoms.separator);

    await _createOrUpdateEventByType(CycleEventType.symptoms, updatedSymptoms);
  }

  Future<void> removeSymptomsEvent(CycleEvent event) async {
    await ref.read(cycleEventsRepositoryProvider).delete(event);
  }

  Future<void> logIntimacy(bool didUseProtection) async {
    await _createOrUpdateEventByType(
      CycleEventType.intimacy,
      didUseProtection ? 'Used protection' : 'Did not use protection',
    );
  }

  Future<void> _createOrUpdateEventByType(
    CycleEventType type,
    String additionalData,
  ) async {
    late CycleEvent? cycleEvent;

    cycleEvent = await ref.read(cycleEventsRepositoryProvider).get({
      'createdBy': ref.read(authRepositoryProvider).getCurrentUser()!.uid,
      'date': Timestamp.fromDate(_date.withoutTime()),
      'type': type.name,
    }).then(
      (value) => value.firstWhereOrNull((e) => isSameDay(e.date, _date)),
    );

    if (cycleEvent != null) {
      cycleEvent = cycleEvent.copyWith(additionalData: additionalData);

      return await ref.read(cycleEventsRepositoryProvider).update(cycleEvent);
    }

    cycleEvent = CycleEvent(
      date: _date,
      type: type,
      additionalData: additionalData,
      createdBy: ref.read(authRepositoryProvider).getCurrentUser()!.uid,
    );

    return await ref.read(cycleEventsRepositoryProvider).create(cycleEvent);
  }
}

final logCycleEventStateProvider = NotifierProviderFamily<
    LogCycleEventStateNotifier, LogCycleEventState, CycleEventType>(
  LogCycleEventStateNotifier.new,
);
