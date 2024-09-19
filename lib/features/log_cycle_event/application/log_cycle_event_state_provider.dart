import 'package:awesome_period_tracker/core/constants/strings.dart';
import 'package:awesome_period_tracker/core/extensions/date_time_extensions.dart';
import 'package:awesome_period_tracker/features/home/data/cycle_events_repository.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:awesome_period_tracker/features/home/domain/period_flow.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/domain/log_event_step.dart';
import 'package:awesome_period_tracker/features/pin_login/domain/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

class LogCycleEventStateNotifier
    extends AutoDisposeFamilyNotifier<LogEventStep, LogEventStep> {
  late DateTime _date;

  @override
  LogEventStep build(LogEventStep arg) => arg;

  void setDate(DateTime date) {
    _date = date;
  }

  Future<void> logPeriod(PeriodFlow flow) async {
    await _createOrUpdateEventByType(CycleEventType.period, flow.name);
  }

  Future<void> logSymptoms(
    List<String> symptoms, [
    String? addtionalInfo,
  ]) async {
    symptoms = symptoms.where((s) => s.isNotEmpty).toList();

    if (symptoms.isEmpty) {
      final symptomsEvent = await ref.read(cycleEventsRepositoryProvider).get({
        'date': Timestamp.fromDate(_date.withoutTime()),
        'type': CycleEventType.symptoms.name,
      }).then((value) => value.firstOrNull);

      if (symptomsEvent != null) {
        await ref.read(cycleEventsRepositoryProvider).delete(symptomsEvent);
      }

      return;
    }

    await _createOrUpdateEventByType(
      CycleEventType.symptoms,
      symptoms.join(Strings.symptomSeparator),
    );
  }

  Future<void> removeSymptomsEvent(CycleEvent event) async {
    await ref.read(cycleEventsRepositoryProvider).delete(event);
  }

  Future<void> logIntimacy(bool didUseProtection) async {
    await _createOrUpdateEventByType(
      CycleEventType.intimacy,
      didUseProtection ? Strings.usedProtection : Strings.didNotUseProtection,
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

  void goToStep(LogEventStep step) {
    state = step;
  }
}

final logCycleEventStateProvider = AutoDisposeNotifierProviderFamily<
    LogCycleEventStateNotifier, LogEventStep, LogEventStep>(
  LogCycleEventStateNotifier.new,
);
