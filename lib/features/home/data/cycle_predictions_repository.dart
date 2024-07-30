import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_forecast.dart';
import 'package:awesome_period_tracker/features/home/domain/menstruation_phase.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

class CycleForecastRepository {
  const CycleForecastRepository();

  static const _defaultCycleLength = 28;
  static const _defaultPeriodLength = 6;
  static const _maximumCycleLength = 40;
  static const _systemId = 'system';

  CycleForecast createForecastForEvents(
    List<CycleEvent> events, {
    DateTime? start,
    DateTime? end,
  }) {
    events = _identifyFirstDaysOfPeriods(events);
    events.sort((a, b) => a.date.compareTo(b.date)); // Ensure events are sorted

    final startDate = start ?? events.first.date;
    final endDate = end ?? startDate.add(const Duration(days: 365));

    final dayOfCycle = _getDayOfCurrentCycle(events);
    final averageCycleLength = _calculateAverageCycleLength(events);
    final averagePeriodLength =
        _calculateAveragePeriodDuration(events, CycleEventType.period);
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
    );

    return CycleForecast(
      date: DateTime.now(),
      dayOfCycle: dayOfCycle,
      averageCycleLength: averageCycleLength,
      averagePeriodLength: averagePeriodLength,
      daysUntilNextPeriod: daysUntilNextPeriod,
      phase: phase,
      events: _mergePredictionsWithActualEvents(events, predictions),
    );
  }

  List<CycleEvent> _identifyFirstDaysOfPeriods(List<CycleEvent> events) {
    final processedEvents = <CycleEvent>[];
    CycleEvent? lastPeriodEvent;

    for (final event in events) {
      if (event.type == CycleEventType.period) {
        if (lastPeriodEvent == null ||
            event.date.difference(lastPeriodEvent.date).inDays > 1) {
          // Start of a new period
          processedEvents.add(event);
        } else {
          // Consecutive day of the same period
          processedEvents.add(event);
        }
        lastPeriodEvent = event;
      } else {
        processedEvents.add(event);
      }
    }

    return processedEvents;
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

    if (periodEvents.length < 2) return _defaultCycleLength;

    final periodStarts = <DateTime>[];
    DateTime? lastDate;
    for (final event in periodEvents) {
      if (lastDate == null || event.date.difference(lastDate).inDays > 1) {
        periodStarts.add(event.date);
      }
      lastDate = event.date;
    }

    if (periodStarts.length < 2) return _defaultCycleLength;

    final cycleLengths = <int>[];
    for (int i = 1; i < periodStarts.length; i++) {
      final difference = periodStarts[i].difference(periodStarts[i - 1]).inDays;
      cycleLengths.add(difference);
    }

    final average = cycleLengths.reduce((a, b) => a + b) ~/ cycleLengths.length;

    return (average >= _defaultCycleLength && average <= _maximumCycleLength)
        ? average
        : _defaultCycleLength;
  }

  int _calculateAveragePeriodDuration(
    List<CycleEvent> events,
    CycleEventType type,
  ) {
    final relevantEvents = events.where((e) => e.type == type).toList();

    if (relevantEvents.length < _defaultPeriodLength) {
      return _defaultPeriodLength;
    }

    int durationCount = 1;
    int totalDuration = 1;
    DateTime? previousDate;

    for (final event in relevantEvents.skip(1)) {
      if (previousDate == null ||
          event.date.difference(previousDate).inDays > 1) {
        durationCount++;
      }
      totalDuration++;
      previousDate = event.date;
    }

    final averageDuration = totalDuration ~/ durationCount;
    return (averageDuration >= _defaultPeriodLength)
        ? averageDuration
        : _defaultPeriodLength;
  }

  MenstruationPhase _determineMenstruationPhase(
    int dayOfCycle,
    int averageCycleLength,
    List<CycleEvent> events,
  ) {
    final menstruationDays =
        _calculateAveragePeriodDuration(events, CycleEventType.period);
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
  ) {
    final predictions = <CycleEvent>[];

    // Filter out symptom and intimacy events for prediction purposes
    final filteredEvents = actualEvents
        .where(
          (e) =>
              e.type == CycleEventType.period ||
              e.type == CycleEventType.fertile,
        )
        .toList();

    // Find the most recent actual period event that is the first day of a period
    final mostRecentPeriod =
        filteredEvents.where((e) => e.type == CycleEventType.period).where((e) {
      final index = filteredEvents.indexOf(e);
      return index == 0 ||
          e.date.difference(filteredEvents[index - 1].date).inDays > 1;
    }).lastOrNull;

    // If there's no actual period data, use today as the start date
    final currentDate = mostRecentPeriod?.date ?? DateTime.now();

    // Calculate the number of cycles to predict
    final numberOfCycles =
        ((endDate.difference(currentDate).inDays) / averageCycleLength).ceil();

    for (var cycle = 0; cycle < numberOfCycles; cycle++) {
      final cycleStartDate =
          currentDate.add(Duration(days: cycle * averageCycleLength));

      // Only generate predictions for dates after the most recent actual event
      if (cycleStartDate.isBefore(filteredEvents.last.date)) {
        continue;
      }

      // Menstruation predictions
      for (var day = 0; day < averageDuration; day++) {
        final predictionDate = cycleStartDate.add(Duration(days: day));
        final setAsActualEvent = filteredEvents.any(
          (e) =>
              e.date == cycleStartDate &&
              e.type == CycleEventType.period &&
              !e.isPrediction,
        );

        if (_shouldAddPrediction(
          predictionDate,
          startDate,
          endDate,
          filteredEvents,
          CycleEventType.period,
        )) {
          predictions.add(
            _createPrediction(
              predictionDate,
              CycleEventType.period,
              isPrediction: !setAsActualEvent,
            ),
          );
        }
      }

      // Fertile days future predictions
      final ovulationDay = (averageCycleLength / 2).round();
      final fertileStartDay = ovulationDay - 5;
      final fertileEndDay = ovulationDay;
      for (var day = fertileStartDay; day <= fertileEndDay; day++) {
        final predictionDate = cycleStartDate.add(Duration(days: day));
        if (_shouldAddPrediction(
          predictionDate,
          startDate,
          endDate,
          actualEvents,
          CycleEventType.fertile,
        )) {
          // For fertile day predictions, we assume they are always predictions
          // Hence, we do not need to update the previousIsPrediction status
          predictions.add(
            _createPrediction(
              predictionDate,
              CycleEventType.fertile,
              isPrediction: true,
              // Always true for fertile days in this context
            ),
          );
        }
      }

      // Generate ovulation predictions for previous cycles
      final firstCycleStartDate = currentDate
          .subtract(Duration(days: averageCycleLength * (numberOfCycles - 1)));
      final fertileDuration = fertileEndDay - fertileStartDay + 1;

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
                createdBy: _systemId,
                isPrediction: true,
              ),
            );
          }
        }
      }
    }

    return predictions..sort((a, b) => a.date.compareTo(b.date));
  }

  bool _shouldAddPrediction(
    DateTime predictionDate,
    DateTime startDate,
    DateTime endDate,
    List<CycleEvent> filteredEvents,
    CycleEventType type,
  ) {
    return predictionDate.isAfter(startDate) &&
        predictionDate.isBefore(endDate) &&
        predictionDate.isAfter(filteredEvents.last.date) &&
        !filteredEvents.any((e) => e.date == predictionDate && e.type == type);
  }

  CycleEvent _createPrediction(
    DateTime date,
    CycleEventType type, {
    required bool isPrediction,
  }) {
    return CycleEvent(
      date: date,
      type: type,
      createdBy: _systemId,
      isPrediction: isPrediction,
    );
  }

  List<CycleEvent> _mergePredictionsWithActualEvents(
    List<CycleEvent> actualEvents,
    List<CycleEvent> predictions,
  ) {
    final mergedEvents = [...actualEvents];

    for (final prediction in predictions) {
      if (!mergedEvents
          .any((e) => e.date == prediction.date && e.type == prediction.type)) {
        mergedEvents.add(prediction);
      }
    }

    return mergedEvents..sort((a, b) => a.date.compareTo(b.date));
  }
}

final cyclePredictionsRepositoryProvider = Provider.autoDispose((ref) {
  return const CycleForecastRepository();
});
