import 'package:awesome_period_tracker/core/extensions/list_extensions.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_forecast.dart';
import 'package:awesome_period_tracker/features/home/domain/menstruation_phase.dart';
import 'package:awesome_period_tracker/features/pin_login/domain/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

class CycleForecastRepository {
  final AuthRepository _authRepository;

  const CycleForecastRepository(this._authRepository);

  CycleForecast generateFullCycleForecast(
    List<CycleEvent> events, {
    DateTime? start,
    DateTime? end,
  }) {
    events.sort((a, b) => a.date.compareTo(b.date));

    final startDate = start ?? events.first.date;
    final endDate = end ?? startDate.add(const Duration(days: 365));

    final dayOfCycle = _getDayOfCurrentCycle(events);
    final averageCycleLength = _calculateAverageCycleLength(events);
    final averagePeriodLength =
        _calculateAverageEventDuration(events, CycleEventType.period);
    final averageFertilityWindowLength =
        _calculateAverageEventDuration(events, CycleEventType.fertile);
    final daysUntilNextPeriod =
        _calculateDaysUntilNextPeriod(averageCycleLength, dayOfCycle);
    final phase =
        _determineMenstruationPhase(dayOfCycle, averageCycleLength, events);

    final predictions = _generatePredictions(
      events,
      startDate,
      endDate,
      averageCycleLength,
      averagePeriodLength,
      averageFertilityWindowLength,
    );

    return CycleForecast(
      date: DateTime.now(),
      dayOfCycle: dayOfCycle,
      averageCycleLength: averageCycleLength,
      averagePeriodLength: averagePeriodLength,
      averageFertilityWindowLength: averageFertilityWindowLength,
      daysUntilNextPeriod: daysUntilNextPeriod,
      phase: phase,
      events: _mergePredictionsWithActualEvents(events, predictions),
    );
  }

  int _getDayOfCurrentCycle(List<CycleEvent> events) {
    if (events.isEmpty) return 0;

    final now = DateTime.now();
    final lastPeriod = events.lastWhere((e) => e.type == CycleEventType.period);

    if (isSameDay(lastPeriod.date, now)) {
      return 1;
    } else {
      return now.difference(lastPeriod.date).inDays + 1;
    }
  }

  int _calculateAverageCycleLength(List<CycleEvent> events) {
    final periodEvents = events
        .where((e) => e.type == CycleEventType.period)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (periodEvents.length < 2) return 28; // Default value

    final periodStarts = <DateTime>[];
    DateTime? lastDate;
    for (final event in periodEvents) {
      if (lastDate == null || event.date.difference(lastDate).inDays > 1) {
        periodStarts.add(event.date);
      }
      lastDate = event.date;
    }

    if (periodStarts.length < 2) return 28; // Default value

    final cycleLengths = <int>[];
    for (int i = 1; i < periodStarts.length; i++) {
      final difference = periodStarts[i].difference(periodStarts[i - 1]).inDays;
      cycleLengths.add(difference);
    }

    final average = cycleLengths.reduce((a, b) => a + b) ~/ cycleLengths.length;

    return (average >= 21 && average <= 35)
        ? average
        : 28; // Apply min/max constraints
  }

  int _calculateAverageEventDuration(
    List<CycleEvent> events,
    CycleEventType type,
  ) {
    final relevantEvents = events.where((e) => e.type == type).toList();
    if (relevantEvents.length < 5) return 5;

    int durationCount = 1;
    int totalDuration = 1;
    DateTime? previousDate;

    for (final event in relevantEvents.skip(1)) {
      if (previousDate == null ||
          event.localDate.difference(previousDate).inDays > 1) {
        durationCount++;
      }
      totalDuration++;
      previousDate = event.localDate;
    }

    final averageDuration = totalDuration ~/ durationCount;
    return (averageDuration >= 5) ? averageDuration : 5;
  }

  MenstruationPhase _determineMenstruationPhase(
    int dayOfCycle,
    int averageCycleLength,
    List<CycleEvent> events,
  ) {
    final menstruationDays =
        _calculateAverageEventDuration(events, CycleEventType.period);
    final ovulationDay = (averageCycleLength / 2).round();

    if (dayOfCycle <= menstruationDays) return MenstruationPhase.menstruation;
    if (dayOfCycle < ovulationDay) return MenstruationPhase.follicular;
    if (dayOfCycle == ovulationDay) return MenstruationPhase.ovulation;
    return MenstruationPhase.luteal;
  }

  int _calculateDaysUntilNextPeriod(int averageCycleLength, int dayOfCycle) {
    final daysUntilNextPeriod = averageCycleLength - dayOfCycle;

    return (daysUntilNextPeriod >= 0 &&
            daysUntilNextPeriod <= averageCycleLength)
        ? daysUntilNextPeriod
        : -1;
  }

  List<CycleEvent> _generatePredictions(
    List<CycleEvent> actualEvents,
    DateTime startDate,
    DateTime endDate,
    int averageCycleLength,
    int averageDuration,
    int fertileDuration,
  ) {
    final predictions = <CycleEvent>[];
    final today = DateTime.now();
    final mostRecentPeriod =
        actualEvents.lastWhereOrNull((e) => e.type == CycleEventType.period);
    final currentDate =
        (mostRecentPeriod != null && mostRecentPeriod.date.isBefore(today))
            ? today
            : (mostRecentPeriod?.date ?? today);
    final numberOfCycles =
        ((endDate.difference(currentDate).inDays / averageCycleLength).ceil());

    for (var cycle = 0; cycle < numberOfCycles; cycle++) {
      final cycleStartDate =
          currentDate.add(Duration(days: cycle * averageCycleLength));

      // Menstruation predictions
      for (var day = 0; day < averageDuration; day++) {
        final predictionDate = cycleStartDate.add(Duration(days: day));
        if (predictionDate.isAfter(startDate) &&
            predictionDate.isBefore(endDate) &&
            !actualEvents.any(
              (e) =>
                  isSameDay(e.date, predictionDate) &&
                  e.type == CycleEventType.period,
            )) {
          predictions.add(
            CycleEvent(
              date: predictionDate,
              type: CycleEventType.period,
              createdBy: _authRepository.getCurrentUser()!.uid,
              isPrediction: true,
            ),
          );
        }
      }

      // Fertile day predictions
      final ovulationDay = (averageCycleLength / 2).round();
      final fertileStartDay = ovulationDay - (fertileDuration / 2).round();
      for (var day = fertileStartDay;
          day < fertileStartDay + fertileDuration;
          day++) {
        final predictionDate = cycleStartDate.add(Duration(days: day));
        if (predictionDate.isAfter(startDate) &&
            predictionDate.isBefore(endDate) &&
            !actualEvents.any(
              (e) =>
                  isSameDay(e.date, predictionDate) &&
                  e.type == CycleEventType.fertile,
            )) {
          predictions.add(
            CycleEvent(
              date: predictionDate,
              type: CycleEventType.fertile,
              createdBy: _authRepository.getCurrentUser()!.uid,
              isPrediction: true,
            ),
          );
        }
      }
    }

    // Generate ovulation predictions for previous cycles
    final firstCycleStartDate = currentDate
        .subtract(Duration(days: averageCycleLength * (numberOfCycles - 1)));

    for (var cycle = 0; cycle < numberOfCycles; cycle++) {
      final cycleStartDate =
          firstCycleStartDate.add(Duration(days: cycle * averageCycleLength));

      // Fertile window predictions for each cycle
      final ovulationDay = (averageCycleLength / 2).round();
      final fertileStartDay = ovulationDay - (fertileDuration / 2).round();
      for (var day = fertileStartDay;
          day < fertileStartDay + fertileDuration;
          day++) {
        final predictionDate = cycleStartDate.add(Duration(days: day));
        if (predictionDate.isAfter(startDate) &&
            predictionDate.isBefore(endDate) &&
            !actualEvents.any(
              (e) =>
                  isSameDay(e.date, predictionDate) &&
                  e.type == CycleEventType.fertile,
            )) {
          predictions.add(
            CycleEvent(
              date: predictionDate,
              type: CycleEventType.fertile,
              createdBy: _authRepository.getCurrentUser()!.uid,
              isPrediction: true,
            ),
          );
        }
      }
    }

    return predictions..sort((a, b) => a.date.compareTo(b.date));
  }

  List<CycleEvent> _mergePredictionsWithActualEvents(
    List<CycleEvent> actualEvents,
    List<CycleEvent> predictions,
  ) {
    final mergedEvents = List<CycleEvent>.from(actualEvents);
    mergedEvents.addAll(
      predictions.where(
        (prediction) => !actualEvents.any(
          (actual) =>
              isSameDay(actual.localDate, prediction.localDate) &&
              actual.type == prediction.type,
        ),
      ),
    );

    return mergedEvents..sort((a, b) => a.localDate.compareTo(b.localDate));
  }
}

final cyclePredictionsRepositoryProvider = Provider.autoDispose((ref) {
  return CycleForecastRepository(ref.read(authRepositoryProvider));
});
