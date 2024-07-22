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

enum MenstruationPhase { menstruation, follicular, ovulation, luteal }

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
    int averageCycleLength,
    MenstruationPhase phase,
  ) {
    return '''
Generate a 25-word personalized insight based on a given menstrual cycle data. Provide a friendly, casual message about the user's cycle, period, or health, including expectations for coming days. The menstrual cycle data is as follows:

- Day of cycle: Day $dayOfCycle
- Average cycle length: $averageCycleLength days
- Current phase: ${phase.name}

Tailor the insight as follows:

1. Menstruating: Humorously reference mood changes or common period experiences and symptoms.
2. Follicular: Mention increased energy or motivation, or a fun fact about the current phase.
3. Ovulation: Include a playful joke about increased libido (e.g., "expect to get freaky" or similar).
4. Luteal: Joke about period cravings or share a fun cycle fact. Mention pre-period symptoms.
5. Late period: Offer a fun menstrual cycle fact or normalize late periods with humor.

Guidelines:
- The message CANNOT have emojis and greetings (like "Hello" or "Hi there"). DO NOT USE EMOJIS OR GREETINGS. THIS IS THE MOST IMPORTANT GUIDELINE.
- Make it relevant to the cycle phase without explicitly stating cycle day or length.
- Aim for a lighthearted, positive, and friendly tone.
- Use friendly language and gentle humor.
''';
  }

  Future<Insight> getInsightForDate(DateTime date) async {
    final storageKey = date.withoutTime().toIso8601String();

    if (_sharedPreferences.containsKey(storageKey)) {
      return InsightMapper.fromJson(_sharedPreferences.getString(storageKey)!);
    }

    final cycleEvents = await _cycleEventsRepository.get();
    final dayOfCycle = _calculateDayOfCycle(cycleEvents, date);
    final daysUntilNextPeriod =
        _calculateDaysUntilNextPeriod(cycleEvents, date);
    final averageCycleLength =
        _cyclePredictionsRepository.calculateAverageCycleLength(cycleEvents);
    final phase = _determineMenstruationPhase(
      dayOfCycle,
      averageCycleLength,
      cycleEvents,
    );

    final insights =
        await _generateInsights(dayOfCycle, averageCycleLength, phase);
    final insight = Insight(
      dayOfCycle: _formatDayOfCycle(dayOfCycle),
      daysUntilNextPeriod: _formatDaysUntilNextPeriod(daysUntilNextPeriod),
      insights: insights,
    );

    await _sharedPreferences.setString(storageKey, insight.toJson());
    return insight;
  }

  Future<String> _generateInsights(
    int dayOfCycle,
    int averageCycleLength,
    MenstruationPhase phase,
  ) async {
    try {
      return await _geminiClient.generateContentFromText(
        prompt: _geminiPrompt(dayOfCycle, averageCycleLength, phase),
      );
    } catch (e) {
      return 'An error occurred while generating insights. :-(';
    }
  }

  MenstruationPhase _determineMenstruationPhase(
    int dayOfCycle,
    int averageCycleLength,
    List<CycleEvent> events,
  ) {
    final menstruationDays = _cyclePredictionsRepository
        .calculateAverageEventDuration(events, CycleEventType.period);
    final ovulationDay = (averageCycleLength / 2).round();

    if (dayOfCycle <= menstruationDays) return MenstruationPhase.menstruation;
    if (dayOfCycle < ovulationDay) return MenstruationPhase.follicular;
    if (dayOfCycle == ovulationDay) return MenstruationPhase.ovulation;

    return MenstruationPhase.luteal;
  }

  int _calculateDayOfCycle(List<CycleEvent> events, DateTime date) {
    if (events.isEmpty) return -1;

    final sortedEvents = events.where((e) => !e.isPrediction).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    if (sortedEvents.first.date.isAfter(date)) return -2;
    final lastPeriodStart =
        sortedEvents.firstWhere((e) => e.type == CycleEventType.period);

    return date.difference(lastPeriodStart.date).inDays + 1;
  }

  int _calculateDaysUntilNextPeriod(List<CycleEvent> events, DateTime date) {
    if (events.isEmpty) return -1;

    final sortedEvents = events.where((e) => !e.isPrediction).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final lastPeriod =
        sortedEvents.firstWhere((e) => e.type == CycleEventType.period);
    final averageCycleLength =
        _cyclePredictionsRepository.calculateAverageCycleLength(events);
    final nextPeriodStart =
        lastPeriod.date.add(Duration(days: averageCycleLength));

    if (nextPeriodStart.isBefore(date)) return 0;

    return nextPeriodStart.difference(date).inDays;
  }

  String _formatDayOfCycle(int day) {
    if (day == -1) return 'No cycle data available';
    if (day == -2) return 'Most recent event is future';
    if (day == 1) return 'Day 1 of period';

    return 'Day $day of cycle';
  }

  String _formatDaysUntilNextPeriod(int days) {
    if (days == -1) return 'No data to predict period';
    if (days < 1) return 'Period may be delayed';
    if (days == 0) return 'Period may start today';
    if (days == 1) return 'Period may start tomorrow';

    return '$days days until next period';
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
