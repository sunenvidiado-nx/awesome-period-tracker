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
    // if (_sharedPreferences.containsKey(_insightKey)) {
    //   return InsightMapper.fromJson(_sharedPreferences.getString(_insightKey)!);
    // }

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
      You are a funny yet supportive friend providing casual advice about the menstrual cycle. They are currently on day $dayOfCycle of their cycle, with an average cycle length of $averageCycleLength days, and is currently in the follicular phase. Give this person a friendly, casual message about the follicular phase, including expectations for the coming days. It should be 30 words long and not include emojis or greetings like "Hi" or "Hello".
      ''';
    }

    if (phase == MenstruationPhase.ovulation) {
      return '''
      You are funny yet supportive friend providing casual advice about the menstrual cycle. The person is currently in the ovulation phase, and is currently on day $dayOfCycle of their cycle, with an average cycle length of $averageCycleLength days. Give this person a friendly, casual message about the ovulation phase, including expectations for the coming days. It should be 30 words long and not include emojis or greetings like "Hi" or "Hello". Add joke or quip about being "frisky" or "energetic" during this and the coming days.
      ''';
    }

    if (phase == MenstruationPhase.luteal) {
      if (dayOfCycle > averageCycleLength) {
        return '''
        You are funny yet supportive friend providing casual advice about the menstrual cycle. The person is currently in the luteal phase, and their period is likely late. They are on day $dayOfCycle of their cycle, with an average cycle length of $averageCycleLength days. Craft a friendly, casual message about the luteal phase, including expectations for the coming days. Use friendly language and gentle humor. Limit the response to a maximum of 30 words. Do not use emojis or greetings like "Hi" or "Hello". Maintain a supportive and understanding tone throughout. Consider mentioning common premenstrual symptoms like mood changes, bloating, or food cravings, but maintain a positive and supportive tone. Their period is late, but it's okay! Encourage them to relax and take care of themselves and that late periods are normal. Mention that they are in the luteal phase without explicitly stating that.
        ''';
      }

      return '''
    You are funny yet supportive friend providing casual advice about the menstrual cycle. The person is currently in the luteal phase, and is currently on day $dayOfCycle of their cycle, with an average cycle length of $averageCycleLength days. Craft a friendly, casual message about the luteal phase, including expectations for the coming days. Mention that they are in the luteal phase without explicitly stating cycle day or length. Use friendly language and gentle humor. Limit the response to a maximum of 30 words. Do not use emojis or greetings like "Hi" or "Hello". Maintain a supportive and understanding tone throughout. Consider mentioning common premenstrual symptoms like mood changes, and physical symptoms but don't mention specific physical symptoms that might make them feel bad about themselves. Encourage them to take care of themselves and practice self-care.
      ''';
    }

    if (phase == MenstruationPhase.menstruation) {
      return '''
    You are funny yet supportive friend providing casual advice about the menstrual cycle. The person is currently in the menstruation phase and their period has started. They are on day $dayOfCycle of their cycle, with an average cycle length of $averageCycleLength days. Craft a friendly, casual message about the menstruation phase, including expectations for the coming days. Use friendly language and gentle humor. Limit the response to a maximum of 30 words. Do not use emojis or greetings like "Hi" or "Hello". Maintain a supportive and understanding tone throughout. Consider mentioning common menstrual symptoms like cramps, or physical symptoms but don't mention specific physical symptoms that might make them feel bad about themselves. Encourage them to take care of themselves and practice self-care.
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
