import 'package:awesome_period_tracker/app/core/constants/strings.dart';
import 'package:awesome_period_tracker/app/core/extensions/date_time_extensions.dart';
import 'package:awesome_period_tracker/app/state/state_manager.dart';
import 'package:awesome_period_tracker/data/repositories/auth_repository.dart';
import 'package:awesome_period_tracker/data/repositories/cycle_events_repository.dart';
import 'package:awesome_period_tracker/data/repositories/symptoms_repository.dart';
import 'package:awesome_period_tracker/domain/models/cycle_event.dart';
import 'package:awesome_period_tracker/domain/models/cycle_event_type.dart';
import 'package:awesome_period_tracker/domain/models/log_event_step.dart';
import 'package:awesome_period_tracker/domain/models/period_flow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:injectable/injectable.dart';
import 'package:table_calendar/table_calendar.dart';

part 'log_cycle_event_state.dart';
part 'log_cycle_event_state_manager.mapper.dart';

@injectable
class LogCycleEventStateManager extends StateManager<LogCycleEventState> {
  LogCycleEventStateManager(
    this._cycleEventsRepository,
    this._authRepository,
    this._symptomsRepository,
  ) : super(LogCycleEventState.initial());

  final CycleEventsRepository _cycleEventsRepository;
  final AuthRepository _authRepository;
  final SymptomsRepository _symptomsRepository;

  void setStep(LogEventStep step) {
    notifier.value = notifier.value.copyWith(step: step);
  }

  void setDate(DateTime date) {
    notifier.value = notifier.value.copyWith(date: date);
  }

  Future<void> createSymptom(String symptom) async {
    try {
      notifier.value = notifier.value.copyWith(isLoadingSymptoms: true);
      await _symptomsRepository.create(symptom);
    } catch (e) {
      // TODO Handle error
    } finally {
      notifier.value = notifier.value.copyWith(isLoadingSymptoms: false);
    }
  }

  Future<void> clearCachedInsights() async {
    await _authRepository.clearUserCache();
  }

  /// Call this when the user wants to log symptoms.
  Future<void> loadSymptoms(String joinedSelectedSymptoms) async {
    try {
      notifier.value = notifier.value.copyWith(isLoadingSymptoms: true);

      final selectedSymptoms =
          joinedSelectedSymptoms.split(Strings.symptomSeparator);
      final symptoms = await _symptomsRepository.get();

      notifier.value = notifier.value.copyWith(
        selectedSymptoms: selectedSymptoms,
        symptoms: symptoms,
      );
    } catch (e) {
      // TODO Handle error
    } finally {
      notifier.value = notifier.value.copyWith(isLoadingSymptoms: false);
    }
  }

  void toggleSymptom(String symptom) {
    notifier.value = notifier.value.copyWith(
      selectedSymptoms: notifier.value.selectedSymptoms.contains(symptom)
          ? notifier.value.selectedSymptoms.where((s) => s != symptom).toList()
          : [...notifier.value.selectedSymptoms, symptom],
    );
  }

  Future<void> logPeriod(PeriodFlow flow) async {
    await _createOrUpdateEventByType(CycleEventType.period, flow.name);
  }

  Future<void> logSymptoms(
    List<String> symptoms, [
    String? addtionalInfo,
  ]) async {
    try {
      notifier.value = notifier.value.copyWith(isLoading: true);

      symptoms = symptoms.where((s) => s.isNotEmpty).toList();

      if (symptoms.isEmpty) {
        final symptomsEvent = await _cycleEventsRepository.get({
          'date': Timestamp.fromDate(notifier.value.date.withoutTime()),
          'type': CycleEventType.symptoms.name,
        }).then((value) => value.firstOrNull);

        if (symptomsEvent != null) {
          await _cycleEventsRepository.delete(symptomsEvent);
        }

        return;
      }

      await _createOrUpdateEventByType(
        CycleEventType.symptoms,
        symptoms.join(Strings.symptomSeparator),
      );
    } catch (e) {
      // TODO Handle error
    } finally {
      notifier.value = notifier.value.copyWith(isLoading: false);
    }
  }

  Future<void> logIntimacy(bool didUseProtection) async {
    try {
      notifier.value = notifier.value.copyWith(isLoading: true);

      await _createOrUpdateEventByType(
        CycleEventType.intimacy,
        didUseProtection ? Strings.usedProtection : Strings.didNotUseProtection,
      );
    } catch (e) {
      // TODO Handle error
    } finally {
      notifier.value = notifier.value.copyWith(isLoading: false);
    }
  }

  Future<void> removeEvent(CycleEvent event) async {
    try {
      notifier.value = notifier.value.copyWith(isLoading: true);
      await _cycleEventsRepository.delete(event);
    } catch (e) {
      // TODO Handle error
    } finally {
      notifier.value = notifier.value.copyWith(isLoading: false);
    }
  }

  Future<void> _createOrUpdateEventByType(
    CycleEventType type,
    String additionalData,
  ) async {
    late CycleEvent? cycleEvent;

    cycleEvent = await _cycleEventsRepository.get({
      'createdBy': _authRepository.getCurrentUser()!.uid,
      'date': Timestamp.fromDate(notifier.value.date.withoutTime()),
      'type': type.name,
    }).then(
      (value) =>
          value.firstWhereOrNull((e) => isSameDay(e.date, notifier.value.date)),
    );

    if (cycleEvent != null) {
      cycleEvent = cycleEvent.copyWith(additionalData: additionalData);

      return await _cycleEventsRepository.update(cycleEvent);
    }

    cycleEvent = CycleEvent(
      date: notifier.value.date,
      type: type,
      additionalData: additionalData,
      createdBy: _authRepository.getCurrentUser()!.uid,
    );

    return await _cycleEventsRepository.create(cycleEvent);
  }
}
