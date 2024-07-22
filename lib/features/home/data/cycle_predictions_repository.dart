// ignore_for_file: prefer_const_constructors

import 'package:awesome_period_tracker/core/extensions/list_extensions.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:awesome_period_tracker/features/pin_login/domain/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

class CyclePredictionsRepository {
  const CyclePredictionsRepository(this._authRepository);
  final AuthRepository _authRepository;

  /// Generates cycle predictions (period and ovulation) for the given [events].
  List<CycleEvent> generateFullCyclePredictions(
    List<CycleEvent> events, {
    DateTime? start,
    DateTime? end,
  }) {
    final periodPredictions = _generatePredictions(
      events,
      CycleEventType.period,
      start: start,
      end: end,
    );
    final ovulationPredictions = _generatePredictions(
      events,
      CycleEventType.fertile,
      start: start,
      end: end,
    );
    return [...periodPredictions, ...ovulationPredictions]
      ..sort((a, b) => a.localDate.compareTo(b.localDate));
  }

  List<CycleEvent> _generatePredictions(
    List<CycleEvent> events,
    CycleEventType predictionType, {
    DateTime? start,
    DateTime? end,
  }) {
    if (events.isEmpty) return [];

    final sortedEvents = events.where((e) => !e.isPrediction).toList()
      ..sort((a, b) => a.localDate.compareTo(b.localDate));
    final startDate = start ?? DateTime.now();
    final endDate = end ?? startDate.add(const Duration(days: 365));

    final averageCycleLength = _calculateAverage(
      sortedEvents,
      (e) => e.localDate
          .difference(sortedEvents[sortedEvents.indexOf(e) - 1].localDate)
          .inDays,
      defaultValue: 28,
      minValue: 21,
      maxValue: 35,
    );
    final averageDuration =
        calculateAverageEventDuration(sortedEvents, predictionType);

    final predictions = _createPredictions(
      sortedEvents,
      startDate,
      endDate,
      averageCycleLength,
      averageDuration,
      predictionType,
    );

    return _mergePredictionsWithActualEvents(predictions, sortedEvents);
  }

  int _calculateAverage(
    List<CycleEvent> events,
    int Function(CycleEvent) getDifference, {
    required int defaultValue,
    required int minValue,
    required int maxValue,
  }) {
    if (events.length < 2) return defaultValue;

    final total =
        events.skip(1).fold(0, (sum, event) => sum + getDifference(event));
    final average = total ~/ (events.length - 1);

    return (average >= minValue && average <= maxValue)
        ? average
        : defaultValue;
  }

  int calculateAverageEventDuration(
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
    return (averageDuration >= 5 && averageDuration <= 7) ? averageDuration : 5;
  }

  int calculateAverageCycleLength(List<CycleEvent> events) {
    return _calculateAverage(
      events,
      (e) => e.localDate
          .difference(events[events.indexOf(e) - 1].localDate)
          .inDays,
      defaultValue: 28,
      minValue: 21,
      maxValue: 35,
    );
  }

  List<CycleEvent> _createPredictions(
    List<CycleEvent> actualEvents,
    DateTime startDate,
    DateTime endDate,
    int averageCycleLength,
    int averageDuration,
    CycleEventType predictionType,
  ) {
    late DateTime currentDate;

    final today = DateTime.now();
    final predictions = <CycleEvent>[];

    // Find the most recent period event
    final mostRecentPeriod =
        actualEvents.lastWhereOrNull((e) => e.type == CycleEventType.period);

    // Determine where to start predictions
    if (mostRecentPeriod != null && mostRecentPeriod.date.isBefore(today)) {
      // If the most recent period is before today, start predictions from today
      currentDate = today;
    } else {
      // Otherwise, start predictions from the most recent period date
      currentDate = mostRecentPeriod != null ? mostRecentPeriod.date : today;
    }

    // Calculate the number of predictions to make
    final numberOfCycles =
        ((endDate.difference(currentDate).inDays / averageCycleLength).ceil());

    for (var cycle = 0; cycle < numberOfCycles; cycle++) {
      final cycleStartDate =
          currentDate.add(Duration(days: cycle * averageCycleLength));

      for (var day = 0; day < averageDuration; day++) {
        final daysOffset = predictionType == CycleEventType.fertile
            ? ((averageCycleLength / 2).round() - (averageDuration / 2).round())
            : 0;

        final predictionDate =
            cycleStartDate.add(Duration(days: day + daysOffset));

        if (predictionDate.isAfter(startDate) &&
            predictionDate.isBefore(endDate) &&
            !actualEvents.any((e) => isSameDay(e.date, predictionDate))) {
          predictions.add(
            CycleEvent(
              date: predictionDate,
              type: predictionType,
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
    List<CycleEvent> predictions,
    List<CycleEvent> actualEvents,
  ) {
    final mergedEvents = List<CycleEvent>.from(actualEvents);
    mergedEvents.addAll(
      predictions.where(
        (prediction) => !actualEvents
            .any((actual) => isSameDay(actual.localDate, prediction.localDate)),
      ),
    );

    return mergedEvents..sort((a, b) => a.localDate.compareTo(b.localDate));
  }
}

final cyclePredictionsRepositoryProvider = Provider.autoDispose((ref) {
  return CyclePredictionsRepository(ref.read(authRepositoryProvider));
});
