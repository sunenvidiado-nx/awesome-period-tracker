import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:awesome_period_tracker/features/pin_login/domain/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

class PeriodPredictionsRepository {
  const PeriodPredictionsRepository(this._authRepository);

  final AuthRepository _authRepository;

  /// Generates a forecast of period events based on the given [events].
  ///
  /// The forecast will be generated from the first event in the list to the last event.
  ///
  /// The [start] and [end] parameters can be used to specify the range of dates to generate predictions for.
  ///
  /// If [start] is not provided, it will default to the current date.
  ///
  /// If [end] is not provided, it will default to [start] + 365 days.
  List<CycleEvent> generatePeriodPredictions(
    List<CycleEvent> events, {
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
    final averageBleedingDuration =
        _calculateAverageBleedingDuration(sortedEvents);

    final actualEventsInRange = sortedEvents
        .where(
          (e) =>
              !e.isPrediction &&
              e.date.isAfter(adjustedStart.subtract(const Duration(days: 1))) &&
              e.date.isBefore(end!.add(const Duration(days: 1))),
        )
        .toList();

    final predictions = _generatePredictions(
      actualEventsInRange,
      adjustedStart,
      end,
      averageCycleLength,
      averageBleedingDuration,
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

  int _calculateAverageBleedingDuration(List<CycleEvent> events) {
    final actualPeriodEvents = events
        .where((e) => !e.isPrediction && e.type == CycleEventType.period)
        .toList();

    // Period lengths vary from 2 to 7 days, but we're using 5 by default
    // since my partner's period lasts 5 days on average :-D
    if (actualPeriodEvents.length < 5) {
      return 5; // Default to 5 if not enough data
    }

    int totalDuration = 0;
    int periodCount = 0;
    DateTime? previousDate;

    for (final event in actualPeriodEvents) {
      if (previousDate == null ||
          event.date.difference(previousDate).inDays > 1) {
        // If it's the first event or not consecutive, start a new period
        periodCount++;
      }

      // For consecutive days, this will just keep adding to the current period's duration
      totalDuration++;

      previousDate = event.date;
    }

    final averageBleedingDuration =
        periodCount == 0 ? 7 : totalDuration ~/ periodCount;

    if (averageBleedingDuration < 5 || averageBleedingDuration > 7) {
      return 5; // Default to 5 if the average is out of range
    }

    return averageBleedingDuration;
  }

  List<CycleEvent> _generatePredictions(
    List<CycleEvent> actualEvents,
    DateTime startDate,
    DateTime endDate,
    int averageCycleLength,
    int averageBleedingDuration,
  ) {
    final predictions = <CycleEvent>[];

    // Handle predictions for past events
    for (var i = 0; i < actualEvents.length; i++) {
      final event = actualEvents[i];
      DateTime currentDate = event.date;

      for (int day = 0; day < averageBleedingDuration; day++) {
        final predictionDay = currentDate.add(Duration(days: day));

        if (predictionDay.isAfter(startDate) &&
            predictionDay.isBefore(endDate)) {
          // Check if this day is not already in actualEvents
          if (!actualEvents.any((e) => isSameDay(e.date, predictionDay))) {
            predictions.add(
              CycleEvent(
                date: predictionDay,
                type: CycleEventType.period,
                createdBy: _authRepository.getCurrentUser()!.uid,
                isPrediction: true,
              ),
            );
          }
        }
      }

      // Generate predictions for future cycles
      while (currentDate.isBefore(endDate)) {
        currentDate = currentDate.add(Duration(days: averageCycleLength));

        for (int day = 0; day < averageBleedingDuration; day++) {
          final predictionDay = currentDate.add(Duration(days: day));

          if (predictionDay.isAfter(startDate) &&
              predictionDay.isBefore(endDate)) {
            predictions.add(
              CycleEvent(
                date: predictionDay,
                type: CycleEventType.period,
                createdBy: _authRepository.getCurrentUser()!.uid,
                isPrediction: true,
              ),
            );
          }
        }
      }
    }

    // Sort and remove duplicates
    predictions.sort((a, b) => a.date.compareTo(b.date));

    return predictions.toSet().toList();
  }

  List<CycleEvent> _mergePredictionsWithActualEvents(
    List<CycleEvent> predictions,
    List<CycleEvent> actualEvents,
  ) {
    final mergedEvents = List<CycleEvent>.from(actualEvents);

    for (final prediction in predictions) {
      final bool overlaps = actualEvents.any(
        (actual) =>
            actual.date.year == prediction.date.year &&
            actual.date.month == prediction.date.month &&
            actual.date.day == prediction.date.day,
      );

      if (!overlaps) {
        mergedEvents.add(prediction);
      }
    }

    mergedEvents.sort((a, b) => a.date.compareTo(b.date));
    return mergedEvents;
  }
}

final periodPredictionsRepositoryProvider = Provider.autoDispose((ref) {
  return PeriodPredictionsRepository(ref.read(authRepositoryProvider));
});
