import 'package:awesome_period_tracker/core/extensions/date_time_extensions.dart';
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

  CycleForecast createForecastForDateFromEvents({
    required DateTime date,
    required List<CycleEvent> events,
    DateTime? start,
    DateTime? end,
  }) {
    events.sort((a, b) => a.date.compareTo(b.date));

    final startDate = start ?? events.first.date;
    final endDate = end ?? startDate.add(const Duration(days: 365));

    final dayOfCycle = _getDayOfCurrentCycle(events, date);
    final averageCycleLength = _calculateAverageCycleLength(events);
    final averagePeriodLength =
        _calculateAveragePeriodDuration(events, CycleEventType.period);
    final daysUntilNextPeriod =
        _calculateDaysUntilNextPeriod(averageCycleLength, dayOfCycle);

    final predictions = _generatePredictions(
      events,
      startDate,
      endDate,
      averageCycleLength,
      averagePeriodLength,
    );

    final mergedEvents = _mergePredictionsWithActualEvents(events, predictions);

    final periodOrOvulationToday = mergedEvents.firstWhereOrNull(
      (e) =>
          isSameDay(e.date, date) &&
          (e.type == CycleEventType.fertile || e.type == CycleEventType.period),
    );

    final phase = _determineMenstruationPhase(
      dayOfCycle,
      averageCycleLength,
      periodOrOvulationToday,
    );

    final eventsForDate =
        mergedEvents.where((e) => isSameDay(e.date, date)).toList();

    return CycleForecast(
      date: date,
      dayOfCycle: dayOfCycle,
      averageCycleLength: averageCycleLength,
      averagePeriodLength: averagePeriodLength,
      daysUntilNextPeriod: daysUntilNextPeriod,
      phase: phase,
      events: mergedEvents,
      eventsForDate: eventsForDate,
    );
  }

  int _getDayOfCurrentCycle(List<CycleEvent> events, DateTime now) {
    if (events.isEmpty) return 0;

    final mostRecentPeriod =
        events.lastWhere((e) => e.type == CycleEventType.period);

    final periodSearchStartDate = mostRecentPeriod.date
        .withoutTime()
        .subtract(const Duration(days: _defaultPeriodLength));
    final periodSearchEndDate = mostRecentPeriod.date
        .withoutTime()
        .add(const Duration(days: _defaultPeriodLength));

    final periodEventsInCurrentCycle = events
        .where(
          (e) =>
              e.date.isAfter(periodSearchStartDate) &&
              e.date.isBefore(periodSearchEndDate) &&
              e.type == CycleEventType.period,
        )
        .toList();

    if (periodEventsInCurrentCycle.length < 2) {
      return now.difference(mostRecentPeriod.date).inDays + 1;
    }

    return now.difference(periodEventsInCurrentCycle.first.date).inDays + 1;
  }

  int _calculateAverageCycleLength(List<CycleEvent> events) {
    final periodEvents = events
        .where((e) => e.type == CycleEventType.period)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (periodEvents.isEmpty) return _defaultCycleLength;

    final cycleStarts = [periodEvents.first.date.withoutTime()];
    for (final event in periodEvents) {
      final eventDate = event.date.withoutTime();
      bool isNewCycle = true;
      for (final cycleStart in cycleStarts) {
        final daysDiff = eventDate.difference(cycleStart).inDays.abs();
        if (daysDiff <= _defaultPeriodLength) {
          isNewCycle = false;
          break;
        }
      }
      if (isNewCycle) {
        cycleStarts.add(eventDate);
      }
    }

    if (cycleStarts.length < 2) return _defaultCycleLength;

    final cycleLengths = [];
    for (var i = 1; i < cycleStarts.length; i++) {
      final cycleLength = cycleStarts[i].difference(cycleStarts[i - 1]).inDays;
      cycleLengths.add(cycleLength);
    }

    final averageCycleLength =
        cycleLengths.reduce((a, b) => a + b) ~/ cycleLengths.length;

    return (averageCycleLength >= _defaultCycleLength &&
            averageCycleLength <= _maximumCycleLength)
        ? averageCycleLength
        : _defaultCycleLength;
  }

  int _calculateAveragePeriodDuration(
    List<CycleEvent> events,
    CycleEventType type,
  ) {
    final relevantEvents = events.where((e) => e.type == type).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (relevantEvents.isEmpty) return _defaultPeriodLength;

    final cycles = <List<DateTime>>[];
    List<DateTime> currentCycle = [relevantEvents.first.date];

    for (var i = 1; i < relevantEvents.length; i++) {
      final currentEventDate = relevantEvents[i].date;
      final lastEventDateInCurrentCycle = currentCycle.last;
      if (currentEventDate.difference(lastEventDateInCurrentCycle).inDays <=
          _defaultPeriodLength) {
        currentCycle.add(currentEventDate);
      } else {
        cycles.add(List.from(currentCycle));
        currentCycle = [currentEventDate];
      }
    }

    cycles.add(currentCycle);

    final periodDurations = cycles.map((cycle) {
      return cycle.last.difference(cycle.first).inDays + 1;
    }).toList();

    final totalDuration =
        periodDurations.fold(0, (sum, duration) => sum + duration);

    final averageDuration = totalDuration ~/ cycles.length;

    return (averageDuration >= _defaultPeriodLength)
        ? averageDuration
        : _defaultPeriodLength;
  }

  MenstruationPhase _determineMenstruationPhase(
    int dayOfCycle,
    int averageCycleLength,
    CycleEvent? event,
  ) {
    if (event != null) {
      if (event.type == CycleEventType.period) {
        return MenstruationPhase.menstruation;
      }

      if (event.type == CycleEventType.fertile) {
        return MenstruationPhase.ovulation;
      }
    }

    if (dayOfCycle <= averageCycleLength ~/ 2) {
      return MenstruationPhase.follicular;
    }

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
    int cycleLengthInDays,
    int periodDurationInDays,
  ) {
    final cycleStartEvents = [actualEvents.first];

    for (final event in actualEvents) {
      final eventDate = event.date.withoutTime();
      bool isNewCycle = true;

      for (final cycleStartEvent in cycleStartEvents) {
        final daysDiff =
            eventDate.difference(cycleStartEvent.date).inDays.abs();
        if (daysDiff <= _defaultPeriodLength || daysDiff >= cycleLengthInDays) {
          isNewCycle = false;
          break;
        }
      }

      if (isNewCycle) cycleStartEvents.add(event);
    }

    // Create first day predictions
    DateTime currentDate = cycleStartEvents.last.date.withoutTime();

    while (currentDate.isBefore(endDate)) {
      currentDate = currentDate.add(Duration(days: cycleLengthInDays + 1));

      cycleStartEvents.add(
        CycleEvent(
          date: currentDate,
          type: CycleEventType.period,
          createdBy: _systemId,
          isPrediction: true,
        ),
      );
    }

    // Create period predictions
    final predictions = <CycleEvent>[];

    for (final cycleStartEvent in cycleStartEvents) {
      var periodStartDate = cycleStartEvent.date.withoutTime();
      final periodEndDate =
          periodStartDate.add(Duration(days: periodDurationInDays));

      // Period predictions
      while (periodStartDate.isBefore(periodEndDate)) {
        predictions.add(
          CycleEvent(
            date: periodStartDate,
            type: CycleEventType.period,
            createdBy: _systemId,
            isPrediction: cycleStartEvent.isPrediction,
          ),
        );

        periodStartDate = periodStartDate.add(const Duration(days: 1));
      }

      // Fertile window predictions
      final ovulationDay =
          cycleStartEvent.date.add(Duration(days: cycleLengthInDays ~/ 2));
      var fertileWindowStart = ovulationDay.subtract(const Duration(days: 4));
      final fertileWindowEnd = ovulationDay.add(const Duration(days: 4));

      while (fertileWindowStart.isBefore(fertileWindowEnd)) {
        predictions.add(
          CycleEvent(
            date: fertileWindowStart,
            type: CycleEventType.fertile,
            createdBy: _systemId,
            // Fertile window predictions are always predictions for now
            isPrediction: true,
          ),
        );

        fertileWindowStart = fertileWindowStart.add(const Duration(days: 1));
      }
    }

    return predictions;
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

final cycleForecastRepositoryProvider = Provider.autoDispose((ref) {
  return const CycleForecastRepository();
});
