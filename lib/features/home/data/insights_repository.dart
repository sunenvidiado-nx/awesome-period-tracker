import 'package:awesome_period_tracker/core/extensions/string_extensions.dart';
import 'package:awesome_period_tracker/core/providers/gemini_client_provider.dart';
import 'package:awesome_period_tracker/core/providers/shared_preferences_provider.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_predictions.dart';
import 'package:awesome_period_tracker/features/home/domain/insight.dart';
import 'package:awesome_period_tracker/features/home/domain/menstruation_phase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

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
      final cachedInsight =
          InsightMapper.fromJson(_sharedPreferences.getString(_insightKey)!);

      if (isSameDay(cachedInsight.date, date.toUtc())) {
        return cachedInsight;
      }
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
      date: date.toUtc(),
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
    String phaseInfo = '';
    String additionalInfo = '';

    switch (phase) {
      case MenstruationPhase.follicular:
        phaseInfo = 'follicular phase';
        additionalInfo =
            'Give expectations for the coming days and about the phase.';
        break;
      case MenstruationPhase.ovulation:
        phaseInfo = 'ovulation phase';
        additionalInfo =
            'Add a joke about being "frisky" or "energetic" during this and coming days.';
        break;
      case MenstruationPhase.luteal:
        phaseInfo = 'luteal phase';
        if (dayOfCycle > averageCycleLength) {
          additionalInfo =
              'Mention common premenstrual symptoms and insights regarding the current phase. Mention that their period is late but it\'s normal. Consider adding a joke about periods or being late.';
        } else {
          additionalInfo =
              'Mention common premenstrual symptoms. Add a joke about this phase and useful facts about it.';
        }
        break;
      case MenstruationPhase.menstruation:
        phaseInfo = 'menstruation phase';
        additionalInfo =
            'Add a witty joke about periods. Encourage self-care and symptom preparedness.';
        break;
    }

    return '''
    CRITICAL INSTRUCTIONS: YOUR RESPONSE MUST BE EXACTLY 30 WORDS OR LESS. NO EMOJIS ALLOWED. NO GREETINGS LIKE "HI" OR "HELLO".

    You are a funny, supportive, and friendly medical expert providing casual advice about the menstrual cycle. The person is on day $dayOfCycle of their $averageCycleLength-day cycle, in the $phaseInfo. Craft a casual, friendly message about this phase. $additionalInfo Use gentle humor and a supportive tone.

    FINAL REMINDER: YOUR RESPONSE MUST BE EXACTLY 25 WORDS OR LESS. NO EMOJIS. NO GREETINGS. FAILURE TO FOLLOW THESE RULES WILL RESULT IN IMMEDIATE TERMINATION OF THIS CONVERSATION.
    '''
        // I know, it's specified already on the prompt, but
        // Gemini is dumb and keeps adding emojis anyway sometimes
        .removeEmojis();
  }
}

final insightsRepositoryProvider = Provider.autoDispose((ref) {
  return InsightsRepository(
    ref.watch(sharedPreferencesProvider),
    ref.watch(geminiClientProvider),
  );
});
