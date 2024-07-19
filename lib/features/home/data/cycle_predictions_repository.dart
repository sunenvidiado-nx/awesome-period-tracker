import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:awesome_period_tracker/features/pin_login/domain/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

class CyclePredictionsRepository {
  const CyclePredictionsRepository(this._authRepository);

  final AuthRepository _authRepository;

  /// Generates a forecast of period events based on the given [events].
  List<CycleEvent> generatePeriodPredictions(
    List<CycleEvent> events, {
    DateTime? start,
    DateTime? end,
  }) {
    return _generatePredictions(
      events,
      CycleEventType.period,
      start: start,
      end: end,
    );
  }

  /// Generates a forecast of ovulation events based on the given [events].
  List<CycleEvent> generateOvulationPredictions(
    List<CycleEvent> events, {
    DateTime? start,
    DateTime? end,
  }) {
    return _generatePredictions(
      events,
      CycleEventType.fertile,
      start: start,
      end: end,
    );
  }

  /// Generates a forecast of both period and ovulation events based on the given [events].
  List<CycleEvent> generateFullCyclePredictions(
    List<CycleEvent> events, {
    DateTime? start,
    DateTime? end,
  }) {
    final periodPredictions =
        generatePeriodPredictions(events, start: start, end: end);
    final ovulationPredictions =
        generateOvulationPredictions(events, start: start, end: end);
    return [...periodPredictions, ...ovulationPredictions]
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<CycleEvent> _generatePredictions(
    List<CycleEvent> events,
    CycleEventType predictionType, {
    DateTime? start,
    DateTime? end,
  }) {
    if (events.isEmpty) return [];

    start ??= DateTime.now();
    end ??= start.add(const Duration(days: 365));

    final sortedEvents = events.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final adjustedStart = sortedEvents.first.date.isBefore(start)
        ? sortedEvents.first.date
        : start;

    final averageCycleLength = calculateAverageCycleLength(sortedEvents);
    final averageDuration = predictionType == CycleEventType.period
        ? calculateAverageBleedingDuration(sortedEvents)
        : calculateAverageFertileWindowDuration(sortedEvents);

    final actualEventsInRange = sortedEvents
        .where(
          (e) =>
              !e.isPrediction &&
              e.date.isAfter(adjustedStart.subtract(const Duration(days: 1))) &&
              e.date.isBefore(end!.add(const Duration(days: 1))),
        )
        .toList();

    final predictions = _createPredictions(
      actualEventsInRange,
      adjustedStart,
      end,
      averageCycleLength,
      averageDuration,
      predictionType,
    );

    return _mergePredictionsWithActualEvents(predictions, actualEventsInRange);
  }

  int calculateAverageCycleLength(List<CycleEvent> events) {
    final actualEvents = events.where((e) => !e.isPrediction).toList();

    if (actualEvents.length < 2) {
      return 28; // Default to 28 if not enough data
    }

    int totalDays = 0;

    for (var i = 1; i < actualEvents.length; i++) {
      totalDays +=
          actualEvents[i].date.difference(actualEvents[i - 1].date).inDays;
    }

    final averageCycleLength = totalDays ~/ (actualEvents.length - 1);

    if (averageCycleLength < 21 || averageCycleLength > 35) {
      return 28; // Default to 28 if the average is out of range
    }

    return averageCycleLength;
  }

  int calculateAverageBleedingDuration(List<CycleEvent> events) {
    final actualPeriodEvents = events
        .where((e) => !e.isPrediction && e.type == CycleEventType.period)
        .toList();

    if (actualPeriodEvents.length < 5) {
      return 5; // Default to 5 if not enough data
    }

    int totalDuration = 0;
    int periodCount = 0;
    DateTime? previousDate;

    for (final event in actualPeriodEvents) {
      if (previousDate == null ||
          event.date.difference(previousDate).inDays > 1) {
        periodCount++;
      }

      totalDuration++;
      previousDate = event.date;
    }

    final averageBleedingDuration =
        periodCount == 0 ? 5 : totalDuration ~/ periodCount;

    if (averageBleedingDuration < 3 || averageBleedingDuration > 7) {
      return 5; // Default to 5 if the average is out of range
    }

    return averageBleedingDuration;
  }

  int calculateAverageFertileWindowDuration(List<CycleEvent> events) {
    final actualOvulationEvents = events
        .where((e) => !e.isPrediction && e.type == CycleEventType.fertile)
        .toList();

    if (actualOvulationEvents.length < 5) {
      return 5; // Default to 5 if not enough data
    }

    int totalDuration = 0;
    int fertilityCount = 0;
    DateTime? previousDate;

    for (final event in actualOvulationEvents) {
      if (previousDate == null ||
          event.date.difference(previousDate).inDays > 1) {
        fertilityCount++;
      }

      totalDuration++;
      previousDate = event.date;
    }

    final averageFertilityDuration =
        fertilityCount == 0 ? 5 : totalDuration ~/ fertilityCount;

    if (averageFertilityDuration < 3 || averageFertilityDuration > 7) {
      return 5; // Default to 5 if the average is out of range
    }

    return averageFertilityDuration;
  }

  List<CycleEvent> _createPredictions(
    List<CycleEvent> actualEvents,
    DateTime startDate,
    DateTime endDate,
    int averageCycleLength,
    int averageDuration,
    CycleEventType predictionType,
  ) {
    final predictions = <CycleEvent>[];

    final mostRecentPeriod = actualEvents.lastWhere(
      (e) => e.type == CycleEventType.period,
      orElse: () => actualEvents.first,
    );

    DateTime currentDate = mostRecentPeriod.date;

    while (currentDate.isBefore(endDate)) {
      final daysOffset = predictionType == CycleEventType.fertile
          ? ((averageCycleLength / 2).round() - (averageDuration / 2).round())
          : 0;

      for (int day = 0; day < averageDuration; day++) {
        final predictionDay = currentDate.add(Duration(days: day + daysOffset));

        if (predictionDay.isAfter(startDate) &&
            predictionDay.isBefore(endDate) &&
            !actualEvents.any((e) => isSameDay(e.date, predictionDay))) {
          predictions.add(
            CycleEvent(
              date: predictionDay,
              type: predictionType,
              createdBy: _authRepository.getCurrentUser()!.uid,
              isPrediction: true,
            ),
          );
        }
      }

      currentDate = currentDate.add(Duration(days: averageCycleLength));
    }

    return predictions..sort((a, b) => a.date.compareTo(b.date));
  }

  List<CycleEvent> _mergePredictionsWithActualEvents(
    List<CycleEvent> predictions,
    List<CycleEvent> actualEvents,
  ) {
    final mergedEvents = List<CycleEvent>.from(actualEvents);

    for (final prediction in predictions) {
      final bool overlaps = actualEvents.any(
        (actual) => isSameDay(actual.date, prediction.date),
      );

      if (!overlaps) {
        mergedEvents.add(prediction);
      }
    }

    return mergedEvents..sort((a, b) => a.date.compareTo(b.date));
  }
}

final cyclePredictionsRepositoryProvider = Provider.autoDispose((ref) {
  return CyclePredictionsRepository(ref.read(authRepositoryProvider));
});
