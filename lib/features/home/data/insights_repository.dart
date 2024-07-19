import 'package:awesome_period_tracker/core/extensions/date_time_extensions.dart';
import 'package:awesome_period_tracker/core/providers/gemini_client_provider.dart';
import 'package:awesome_period_tracker/core/providers/shared_preferences_provider.dart';
import 'package:awesome_period_tracker/features/home/data/cycle_events_repository.dart';
import 'package:awesome_period_tracker/features/home/data/cycle_predictions_repository.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:awesome_period_tracker/features/home/domain/insight.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _MenstruationPhase {
  menstruation,
  follicular,
  ovulation,
  luteal;
}

class InsightsRepository {
  const InsightsRepository(
    this._cyclePredictionsRepository,
    this._cycleEventsRepository,
    this._sharedPreferences,
    this._geminiClient,
  );

  final CyclePredictionsRepository _cyclePredictionsRepository;
  final CycleEventsRepository _cycleEventsRepository;
  final SharedPreferences _sharedPreferences;
  final GeminiClient _geminiClient;

  static String _geminiPrompt(
    int dayOfCycle,
    int cycleLengthInDays,
    _MenstruationPhase menstruationPhase,
  ) {
    return '''
Generate a 25-word personalized insight based on a given menstrual cycle data. Provide a friendly, casual message about the user's cycle, period, or health, including expectations for coming days. Tailor the message as follows:

1. Menstruating: Humorously reference mood changes or common period experiences and symptoms.
2. Follicular: Mention increased energy or motivation, or a fun fact about the current phase.
3. Ovulation: Include a playful joke about increased libido (e.g., "expect to get freaky" or similar).
4. Luteal: Joke about period cravings or share a fun cycle fact. Mention pre-period symptoms.
5. Late period: Offer a fun menstrual cycle fact or normalize late periods with humor.

Guidelines:
- Make it relevant to the cycle phase without explicitly stating cycle day or length.
- Aim for a lighthearted, positive, and friendly tone.
- Use friendly language and gentle humor.
- MUST exclude emojis and greetings.

The menstrual cycle data is as follows:

- Day of cycle: Day $dayOfCycle
- Average cycle length: $cycleLengthInDays days
- Current phase: ${menstruationPhase.name}
''';
  }

  Future<Insight> getInsightForDate(DateTime date) async {
    late String insights;

    final storageKey = date.withoutTime().toIso8601String();

    if (_sharedPreferences.containsKey(storageKey)) {
      return InsightMapper.fromJson(_sharedPreferences.getString(storageKey)!);
    }

    final cycleEvents = await _cycleEventsRepository.get();
    final dayOfCycle = _getDayOfCycleFromEvents(cycleEvents, date);
    final daysUntilNextPeriod =
        _getDaysBeforeNextPeriodFromEvents(cycleEvents, date);

    final averageCycleLength = _getAverageCycleLengthFromEvents(cycleEvents);
    final dayOfCycleString = _dayOfCycleToString(dayOfCycle);
    final daysUntilNextPeriodString =
        _daysUntilNextPeriodToString(daysUntilNextPeriod);

    final menstruationPhase = _determineMenstruationPhase(
      dayOfCycle,
      averageCycleLength,
      cycleEvents,
    );

    try {
      insights = await _getInsightsFromGemini(
        dayOfCycle,
        averageCycleLength,
        menstruationPhase,
      );
    } catch (e) {
      insights = 'An error occurred while generating insights. :-(';
    }

    final insight = Insight(
      dayOfCycle: dayOfCycleString,
      daysUntilNextPeriod: daysUntilNextPeriodString,
      insights: insights,
    );

    await _sharedPreferences.setString(storageKey, insight.toJson());

    return insight;
  }

  _MenstruationPhase _determineMenstruationPhase(
    int dayOfCycle,
    int averageCycleLength,
    List<CycleEvent> cycleEvents,
  ) {
    final menstruationDays = _cyclePredictionsRepository
        .calculateAverageBleedingDuration(cycleEvents);

    final ovulationDay =
        (averageCycleLength / 2).round(); // Approx. middle of the cycle

    if (dayOfCycle <= menstruationDays) {
      return _MenstruationPhase.menstruation;
    } else if (dayOfCycle < ovulationDay) {
      return _MenstruationPhase.follicular;
    } else if (dayOfCycle == ovulationDay) {
      return _MenstruationPhase.ovulation;
    } else {
      return _MenstruationPhase.luteal;
    }
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

  bool _isFertile(List<CycleEvent> cycleEvents, DateTime today) {
    // Find the most recent period event before today
    final currentCycleStartDate = _getCurrentCycleStartDate(cycleEvents, today);

    // If no start date is found, assume not fertile
    if (currentCycleStartDate == null) return false;

    // Calculate the day of the cycle
    final dayOfCycle = today.difference(currentCycleStartDate).inDays + 1;

    // Check if the day of the cycle is within the fertile window
    return dayOfCycle >= 10 && dayOfCycle <= 17;
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
    _MenstruationPhase menstruationPhase,
  ) async {
    final result = await _geminiClient.generateContentFromText(
      prompt: _geminiPrompt(
        dayOfCycle,
        cycleLengthInDays,
        menstruationPhase,
      ),
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
    return _cyclePredictionsRepository.calculateAverageCycleLength(cycleEvents);
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
    ref.watch(cyclePredictionsRepositoryProvider),
    ref.watch(cycleEventsRepositoryProvider),
    ref.watch(sharedPreferencesProvider),
    ref.watch(geminiClientProvider),
  );
});
