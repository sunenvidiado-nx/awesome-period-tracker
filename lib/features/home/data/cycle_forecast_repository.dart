import 'package:awesome_period_tracker/core/environment/env.dart';
import 'package:awesome_period_tracker/core/extensions/date_time_extensions.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_forecast.dart';
import 'package:awesome_period_tracker/features/home/domain/menstruation_phase.dart';
import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:table_calendar/table_calendar.dart';

@injectable
class CycleForecastRepository {
  const CycleForecastRepository(this._env);

  final Env _env;

  static const _defaultCycleLength = 28;
  static const _defaultPeriodLength = 6;

  CycleForecast createForecastForDateFromEvents({
    required DateTime date,
    required List<CycleEvent> events,
    DateTime? start,
    DateTime? end,
  }) {
    events.sort((a, b) => a.date.compareTo(b.date));

    final startDate = start ?? events.firstOrNull?.date ?? date;
    final endDate = end ?? startDate.add(const Duration(days: 365));

    final dayOfCycle = _getDayOfCurrentCycle(events, date);
    final averageCycleLength = _calculateAverageCycleLength(events);
    final averagePeriodLength =
        _calculateAveragePeriodDuration(events, CycleEventType.period);

    final predictions = _generatePredictions(
      events,
      startDate,
      endDate,
      averageCycleLength,
      averagePeriodLength,
    );

    final mergedEvents = _mergePredictionsWithActualEvents(events, predictions);

    final nextPeriod = mergedEvents.firstWhereOrNull(
      (e) => e.date.isAfter(date) && e.type == CycleEventType.period,
    );

    final isCurrentlyInPeriod = mergedEvents
        .where((e) => e.type == CycleEventType.period && !e.isPrediction)
        .any(
          (e) =>
              isSameDay(e.date, date) ||
              e.date.isBefore(date) &&
                  date.difference(e.date).inDays < averagePeriodLength,
        );

    final daysUntilNextPeriod = isCurrentlyInPeriod
        ? 0
        : (nextPeriod != null ? nextPeriod.date.difference(date).inDays : -1);

    final eventToday =
        mergedEvents.firstWhereOrNull((e) => isSameDay(e.date, date));

    final hasPeriodBeenLoggedRecently = events
        .where((e) => e.type == CycleEventType.period && !e.isPrediction)
        .any(
          (e) => e.date.difference(date).inDays.abs() <= averagePeriodLength,
        );

    final phase = _determineMenstruationPhase(
      dayOfCycle,
      averageCycleLength,
      eventToday,
      hasPeriodBeenLoggedRecently,
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
    if (events.isEmpty) return 1;

    final recentPeriods = events
        .where(
          (e) =>
              e.type == CycleEventType.period &&
              !e.isPrediction &&
              !e.date.isAfter(now),
        )
        .toList();

    if (recentPeriods.isEmpty) return 1;

    late DateTime periodStart;

    recentPeriods.sort((a, b) => b.date.compareTo(a.date));

    for (final period in recentPeriods) {
      final index = recentPeriods.indexOf(period);
      final previousPeriod = recentPeriods[index + 1];

      if (period.date.difference(previousPeriod.date).inDays > 1) {
        periodStart = period.date;
        break;
      }
    }

    return now.difference(periodStart).inDays + 1;
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

    return (averageCycleLength >= _defaultCycleLength)
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
    CycleEvent? eventToday,
    bool hasPeriodBeenLoggedRecently,
  ) {
    // If a period has been logged recently, trust that over predictions
    if (hasPeriodBeenLoggedRecently) {
      return MenstruationPhase.menstruation;
    }

    // If there's an event today, use it to determine the phase
    if (eventToday != null) {
      if (eventToday.type == CycleEventType.period &&
          !eventToday.isPrediction) {
        return MenstruationPhase.menstruation;
      }
      if (eventToday.type == CycleEventType.fertile) {
        return MenstruationPhase.ovulation;
      }
    }

    // If no specific event, determine phase based on cycle day
    if (dayOfCycle <= averageCycleLength * 0.2) {
      return MenstruationPhase.follicular;
    } else if (dayOfCycle <= averageCycleLength * 0.4) {
      return MenstruationPhase.ovulation;
    } else if (dayOfCycle <= averageCycleLength) {
      return MenstruationPhase.luteal;
    } else {
      // If we're past the expected cycle length, assume late luteal phase
      return MenstruationPhase.luteal;
    }
  }

  List<CycleEvent> _generatePredictions(
    List<CycleEvent> actualEvents,
    DateTime startDate,
    DateTime endDate,
    int cycleLengthInDays,
    int periodDurationInDays,
  ) {
    late DateTime nextPredictedPeriodStart;
    final predictions = <CycleEvent>[];
    final now = DateTime.now().withoutTime();

    // Find the most recent actual period
    final lastActualPeriod = actualEvents
        .where((e) => e.type == CycleEventType.period && !e.isPrediction)
        .lastOrNull;

    if (lastActualPeriod != null) {
      nextPredictedPeriodStart =
          lastActualPeriod.date.add(Duration(days: cycleLengthInDays));
      // If the predicted start is in the past, shift it to today
      if (nextPredictedPeriodStart.isBefore(now)) {
        nextPredictedPeriodStart = now;
      }
    } else {
      // If no actual period data, start predictions from today
      nextPredictedPeriodStart = now;
    }

    while (nextPredictedPeriodStart.isBefore(endDate)) {
      // Generate period predictions
      for (int i = 0; i < periodDurationInDays; i++) {
        final periodDay = nextPredictedPeriodStart.add(Duration(days: i));
        predictions.add(
          CycleEvent(
            date: periodDay,
            type: CycleEventType.period,
            createdBy: _env.systemId,
            isPrediction: true,
          ),
        );
      }

      // Generate fertile window predictions
      final ovulationDay =
          nextPredictedPeriodStart.add(Duration(days: cycleLengthInDays ~/ 2));

      for (int i = -4; i <= 4; i++) {
        final fertileDay = ovulationDay.add(Duration(days: i));

        predictions.add(
          CycleEvent(
            date: fertileDay,
            type: CycleEventType.fertile,
            createdBy: _env.systemId,
            isPrediction: true,
          ),
        );
      }

      // Move to the next cycle
      nextPredictedPeriodStart =
          nextPredictedPeriodStart.add(Duration(days: cycleLengthInDays));
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
