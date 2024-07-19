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

  static String _geminiPrompt(int dayOfCycle, int cycleLengthInDays) {
    return '''
      Day of cycle: $dayOfCycle
      Cycle length: $cycleLengthInDays

      Generate a personalized insight for a user based on the given menstrual cycle data above. Provide a friendly, informative message (max 25 words) about their cycle, period, or general health, including expectations for coming days. If in the ovulation window, include a witty joke about increased libido. If likely menstruating, incorporate a lighthearted reference to mood changes or common period experiences, along with a witty remark. Ensure the output excludes emojis.
    ''';
  }

  Future<Insight> getInsightForDate(DateTime date) async {
    final boxKey = date.withoutTime().toIso8601String();

    if (_insightsBox.containsKey(boxKey)) {
      return InsightMapper.fromJson(_insightsBox.get(boxKey)!);
    }

    final cycleEvents = await _cycleEventsRepository.getCycleEvents();

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

    final insights =
        await _getInsightsFromGemini(dayOfCycle, averageCycleLength);

    final insight = Insight(
      dayOfCycle: dayOfCycleString,
      daysUntilNextPeriod: daysUntilNextPeriodString,
      insights: insights,
    );

    await _insightsBox.put(boxKey, insight.toJson());

    return insight;
  }

  Future<String> _getInsightsFromGemini(
    int dayOfCycle,
    int cycleLengthInDays,
  ) async {
    final result = await _geminiClient.generateContentFromText(
      prompt: _geminiPrompt(dayOfCycle, cycleLengthInDays),
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
