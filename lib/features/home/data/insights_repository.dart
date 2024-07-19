import 'package:awesome_period_tracker/core/extensions/date_time_extensions.dart';
import 'package:awesome_period_tracker/core/providers/gemini_client_provider.dart';
import 'package:awesome_period_tracker/core/providers/insights_box_provider.dart';
import 'package:awesome_period_tracker/features/home/data/cycle_events_repository.dart';
import 'package:awesome_period_tracker/features/home/data/period_predictions_repository.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:awesome_period_tracker/features/home/domain/insight.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InsightsRepository {
  const InsightsRepository(
    this._periodPredictionsRepository,
    this._cycleEventsRepository,
    this._insightsBox,
    this._geminiClient,
  );

  final PeriodPredictionsRepository _periodPredictionsRepository;
  final CycleEventsRepository _cycleEventsRepository;
  final Box<String> _insightsBox;
  final GeminiClient _geminiClient;

  static String _geminiPrompt(
    int dayOfCycle,
    int cycleLengthInDays,
    bool hasPeriod,
  ) {
    return '''
Generate a personalized insight based on the following menstrual cycle data:

Day of cycle: $dayOfCycle
Cycle length: $cycleLengthInDays
Has period: $hasPeriod

Provide a friendly, informative message (max 25 words) about the user's cycle, period, or general health, including expectations for coming days. Tailor the message as follows:

1. If likely in the ovulation window: Include a witty joke about increased libido or sexual drive (e.g., "expect to get freaky").
2. If on period: Incorporate a lighthearted reference to mood changes or common period experiences, with a witty remark.
3. If not on period and it's late: Offer a fun fact about the menstrual cycle or a joke about period cravings, and maybe mention that late periods are normal.

The insight should be relevant to the cycle phase without explicitly stating the cycle day or cycle length. Exclude emojis and greetings.
''';
  }

  Future<Insight> getInsightForDate(DateTime date) async {
    final boxKey = date.withoutTime().toIso8601String();

    if (_insightsBox.containsKey(boxKey)) {
      return InsightMapper.fromJson(_insightsBox.get(boxKey)!);
    }

    final cycleEvents = await _cycleEventsRepository.get();

    if (cycleEvents.first.date.isAfter(date)) {
      return const Insight(
        dayOfCycle: 'No data available',
        daysUntilNextPeriod: 'No data for predictions',
        insights:
            'Most recent event is in the future. You can go to future events to see insights.',
      );
    }

    final dayOfCycle = _getDayOfCycleFromEvents(cycleEvents, date);
    final daysUntilNextPeriod =
        _getDaysBeforeNextPeriodFromEvents(cycleEvents, date);

    final averageCycleLength = _getAverageCycleLengthFromEvents(cycleEvents);
    final dayOfCycleString = _dayOfCycleToString(dayOfCycle);
    final daysUntilNextPeriodString =
        _daysUntilNextPeriodToString(daysUntilNextPeriod);
    final hasPeriod = _isOnPeriod(cycleEvents, date);

    final insights =
        await _getInsightsFromGemini(dayOfCycle, averageCycleLength, hasPeriod);

    final insight = Insight(
      dayOfCycle: dayOfCycleString,
      daysUntilNextPeriod: daysUntilNextPeriodString,
      insights: insights,
    );

    await _insightsBox.put(boxKey, insight.toJson());

    return insight;
  }

  bool _isOnPeriod(List<CycleEvent> cycleEvents, DateTime today) {
    // Find the most recent period event before today
    final currentCycleStartDate = _getCurrentCycleStartDate(cycleEvents, today);

    // If no start date is found, assume not on period
    if (currentCycleStartDate == null) return false;

    // Check for period events in the current cycle
    return cycleEvents.any(
      (event) =>
          event.date.isAfter(currentCycleStartDate) &&
          event.date.isBefore(today) &&
          event.type == CycleEventType.period,
    );
  }

// Helper method to find the start date of the current cycle based on the most recent period event before today
  DateTime? _getCurrentCycleStartDate(
    List<CycleEvent> cycleEvents, [
    DateTime? today,
  ]) {
    today ??= DateTime.now();

    // Filter for period events before today and sort them in reverse chronological order
    final periodEventsBeforeToday = cycleEvents
        .where(
          (event) =>
              event.type == CycleEventType.period &&
              event.date.isBefore(today!),
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Return the date of the most recent period event as the start of the current cycle
    return periodEventsBeforeToday.isNotEmpty
        ? periodEventsBeforeToday.first.date
        : null;
  }

  Future<String> _getInsightsFromGemini(
    int dayOfCycle,
    int cycleLengthInDays,
    bool hasPeriod,
  ) async {
    final result = await _geminiClient.generateContentFromText(
      prompt: _geminiPrompt(dayOfCycle, cycleLengthInDays, hasPeriod),
    );

    return result;
  }

  int _getDaysBeforeNextPeriodFromEvents(
    List<CycleEvent> cycleEvents,
    DateTime selectedDate,
  ) {
    if (cycleEvents.isEmpty) {
      return -1; // Indicates unable to predict
    }

    cycleEvents.sort((a, b) => b.date.compareTo(a.date));

    final mostRecentPeriodStart = cycleEvents.firstWhere(
      (event) => event.type == CycleEventType.period && !event.isPrediction,
      orElse: () => cycleEvents.first,
    );

    final averageCycleLength = _getAverageCycleLengthFromEvents(cycleEvents);

    final predictedNextPeriodStart =
        mostRecentPeriodStart.date.add(Duration(days: averageCycleLength));

    return predictedNextPeriodStart.difference(selectedDate).inDays;
  }

  int _getAverageCycleLengthFromEvents(List<CycleEvent> cycleEvents) {
    return _periodPredictionsRepository
        .calculateAverageCycleLength(cycleEvents);
  }

  int _getDayOfCycleFromEvents(
    List<CycleEvent> cycleEvents,
    DateTime selectedDate,
  ) {
    if (cycleEvents.isEmpty) {
      return -1; // Indicates unable to determine
    }

    cycleEvents.sort((a, b) => b.date.compareTo(a.date));
    final mostRecentEvent = cycleEvents.first;

    if (mostRecentEvent.date.isAfter(selectedDate)) {
      return -2; // Indicates most recent event is in the future
    }

    final mostRecentPeriodStart =
        cycleEvents.firstWhere((event) => event.type == CycleEventType.period);

    return selectedDate.difference(mostRecentPeriodStart.date).inDays + 1;
  }

  String _dayOfCycleToString(int dayOfCycle) {
    if (dayOfCycle == -1) {
      return 'No cycle data available';
    } else if (dayOfCycle == -2) {
      return 'Most recent event is future';
    } else if (dayOfCycle == 1) {
      return 'Day 1 of period';
    } else {
      return 'Day $dayOfCycle of cycle';
    }
  }

  String _daysUntilNextPeriodToString(int daysUntilNextPeriod) {
    if (daysUntilNextPeriod == -1) {
      return 'No data to predict period';
    } else if (daysUntilNextPeriod < 0) {
      return 'Period may be delayed';
    } else if (daysUntilNextPeriod == 0) {
      return 'Period may start today';
    } else if (daysUntilNextPeriod == 1) {
      return 'Period may start tomorrow';
    } else {
      return '$daysUntilNextPeriod days until next period';
    }
  }
}

final insightsRepositoryProvider = Provider.autoDispose((ref) {
  return InsightsRepository(
    ref.watch(periodPredictionsRepositoryProvider),
    ref.watch(cycleEventsRepositoryProvider),
    ref.watch(insightsBoxProvider),
    ref.watch(geminiClientProvider),
  );
});
