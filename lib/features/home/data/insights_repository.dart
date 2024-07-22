import 'package:awesome_period_tracker/core/providers/gemini_client_provider.dart';
import 'package:awesome_period_tracker/core/providers/shared_preferences_provider.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_predictions.dart';
import 'package:awesome_period_tracker/features/home/domain/insight.dart';
import 'package:awesome_period_tracker/features/home/domain/menstruation_phase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InsightsRepository {
  const InsightsRepository(
    this._sharedPreferences,
    this._geminiClient,
  );

  final SharedPreferences _sharedPreferences;
  final GeminiClient _geminiClient;

  // Generate random strings here: http://bit.ly/random-strings-generator
  static const _insightKey = 'o5EnMpHTYU1l';

  Future<Insight> getInsightForDate(
    DateTime date,
    CyclePredictions predictions,
  ) async {
    if (_sharedPreferences.containsKey(_insightKey)) {
      return InsightMapper.fromJson(_sharedPreferences.getString(_insightKey)!);
    }

    final geminiInsight = await _generateInsights(
      predictions.dayOfCycle,
      predictions.averageCycleLength,
      predictions.phase,
    );

    final insight = Insight(
      dayOfCycle: _formatDayOfCycle(predictions.dayOfCycle),
      daysUntilNextPeriod:
          _formatDaysUntilNextPeriod(predictions.daysUntilNextPeriod),
      insights: geminiInsight,
    );

    await _sharedPreferences.setString(_insightKey, insight.toJson());

    return insight;
  }

  Future<void> clearCache() async {
    await _sharedPreferences.remove(_insightKey);
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

  String _formatDayOfCycle(int day) {
    if (day == -1) return 'No cycle data available';
    if (day == -2) return 'Most recent event is future';
    if (day == 1) return 'Day 1 of period';

    return 'Day $day of cycle';
  }

  String _formatDaysUntilNextPeriod(int days) {
    if (days == -69) return 'No data to predict period';
    if (days < 1) return 'Period may be delayed';
    if (days == 0) return 'Period may start today';
    if (days == 1) return 'Period may start tomorrow';

    return '$days days until next period';
  }

  String _geminiPrompt(
    int dayOfCycle,
    int averageCycleLength,
    MenstruationPhase phase,
  ) {
    if (phase == MenstruationPhase.follicular) {
      return '''
      You are a funny, supportive, and friendly medical expert providing casual advice about the menstrual cycle. Someone is currently on day $dayOfCycle of their cycle, with an average cycle length of $averageCycleLength days, and is currently in the follicular phase. Give this person a casual message about the follicular phase, including expectations for the coming days. It should be 30 words long and not include emojis or greetings like "Hi" or "Hello".
      ''';
    }

    if (phase == MenstruationPhase.ovulation) {
      return '''
        You are a funny, supportive, and friendly medical expert providing casual advice about the menstrual cycle. The person is currently in the ovulation phase, and is currently on day $dayOfCycle of their cycle, with an average cycle length of $averageCycleLength days. Give this person a friendly, casual message about the ovulation phase, including expectations for the coming days. It should be 30 words long and not include emojis or greetings like "Hi" or "Hello". Add joke or quip about being "frisky" or "energetic" during this and the coming days.
      ''';
    }

    if (phase == MenstruationPhase.luteal) {
      if (dayOfCycle > averageCycleLength) {
        return '''
          You are a funny, supportive, and friendly medical expert providing casual advice about the menstrual cycle. The person is currently in the luteal phase, and their period is likely late. They are on day $dayOfCycle of their cycle, with an average cycle length of $averageCycleLength days. Craft a casual message about what they will experiencing during this phase, including expectations for the coming days. Use friendly language and gentle humor. Limit the response to a maximum of 30 words. Do not use emojis or greetings like "Hi" or "Hello". Consider mentioning common premenstrual symptoms. Their period is late, but it's okay! Late periods are normal. Add a joke at the end about periods or being late and encourage them to take care of themselves and be prepared for symptoms.
        ''';
      }

      return '''
      You are a funny, supportive, and friendly medical expert providing casual advice about the menstrual cycle. The person is currently in the luteal phase, and is currently on day $dayOfCycle of their cycle, with an average cycle length of $averageCycleLength days. Craft a friendly, casual message about the current phase, including expectations for the coming days. Mention that they are in the luteal phase without explicitly stating cycle day or length. Use friendly language and gentle humor. Limit the response to a maximum of 30 words. Do not use emojis or greetings like "Hi" or "Hello". Maintain a supportive and understanding tone throughout. Consider mentioning common premenstrual symptoms like mood changes, and physical symptoms but don't mention specific physical symptoms that might make them feel bad about themselves (like bloating or acne). Add a joke about the current phase to cheer them up.
      ''';
    }

    if (phase == MenstruationPhase.menstruation) {
      return '''
      You are a funny, supportive, and friendly medical expert providing casual advice about the menstrual cycle. The person is currently in the menstruation phase and their period has started. They are on day $dayOfCycle of their cycle, with an average cycle length of $averageCycleLength days. Craft a friendly, casual message about the menstruation phase, including expectations for the coming days. Use friendly language and gentle humor. Limit the response to a maximum of 30 words. Do not use emojis or greetings like "Hi" or "Hello". Maintain a supportive and understanding tone throughout. Add a joke about how periods are a natural part of life and encourage them to take care of themselves and be prepared for symptoms. Or any period jokes in general.
      ''';
    }

    return '';
  }
}

final insightsRepositoryProvider = Provider.autoDispose((ref) {
  return InsightsRepository(
    ref.watch(sharedPreferencesProvider),
    ref.watch(geminiClientProvider),
  );
});
