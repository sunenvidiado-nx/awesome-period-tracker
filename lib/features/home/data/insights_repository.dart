import 'package:awesome_period_tracker/core/extensions/date_time_extensions.dart';
import 'package:awesome_period_tracker/core/extensions/string_extensions.dart';
import 'package:awesome_period_tracker/core/providers/gemini_client_provider.dart';
import 'package:awesome_period_tracker/core/providers/shared_preferences_provider.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_forecast.dart';
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

  Future<Insight> getInsightForForecast({
    required CycleForecast forecast,
    bool useCache = true,
  }) async {
    final prefsKey = forecast.date.toYmdString();

    try {
      if (_sharedPreferences.containsKey(prefsKey) && useCache) {
        final cachedInsight =
            InsightMapper.fromJson(_sharedPreferences.getString(prefsKey)!);

        final isCacheValid = isSameDay(
              cachedInsight.date,
              forecast.date.toUtc(),
            ) &&
            cachedInsight.dayOfCycle == forecast.dayOfCycle &&
            cachedInsight.daysUntilNextPeriod == forecast.daysUntilNextPeriod;

        if (isCacheValid) {
          return cachedInsight;
        }
      }
    } catch (e) {
      // On exceptions, do nothing and generate new a new insight.
      // This is to prevent app crashes due to corrupted cache data.
    }

    final geminiInsight = await _generateInsights(
      forecast.dayOfCycle,
      forecast.averageCycleLength,
      forecast.phase,
      false, // TODO Change to dynamic
    );

    final insight = Insight(
      dayOfCycle: forecast.dayOfCycle,
      daysUntilNextPeriod: forecast.daysUntilNextPeriod,
      insights: geminiInsight.removeEmojis(),
      date: forecast.date.toUtc(),
    );

    await _sharedPreferences.setString(prefsKey, insight.toJson());

    return insight;
  }

  Future<void> clearCache() async {
    await _sharedPreferences.clear();
  }

  Future<String> _generateInsights(
    int dayOfCycle,
    int averageCycleLength,
    MenstruationPhase phase,
    bool isPast,
  ) async {
    try {
      return await _geminiClient.generateContentFromText(
        prompt: _geminiPrompt(dayOfCycle, averageCycleLength, phase, isPast),
      );
    } catch (e) {
      return 'An error occurred while generating insights. :-(';
    }
  }

  String _geminiPrompt(
    int dayOfCycle,
    int averageCycleLength,
    MenstruationPhase phase,
    bool isPast,
  ) {
    String phaseInfo;
    String additionalInfo;

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

    if (isPast) {
      return '''
      CRITICAL INSTRUCTIONS: YOUR RESPONSE MUST BE EXACTLY 30 WORDS OR LESS. NO EMOJIS ALLOWED. NO GREETINGS LIKE "HI" OR "HELLO".

      You are a funny, supportive, and friendly medical expert providing a casual summary about a previous menstrual cycle log. The person was on day $dayOfCycle of their $averageCycleLength-day cycle, in the $phaseInfo. Provide a brief summary of what they likely experienced during this phase. $additionalInfo Use gentle humor and a supportive tone. No need to mention which cycle day they are on as that's already provided somewhere else.

      FINAL REMINDER: YOUR RESPONSE MUST BE EXACTLY 25 WORDS OR LESS. NO EMOJIS. NO GREETINGS. FAILURE TO FOLLOW THESE RULES WILL RESULT IN IMMEDIATE TERMINATION OF THIS CONVERSATION.
      ''';
    }

    return '''
    CRITICAL INSTRUCTIONS: YOUR RESPONSE MUST BE EXACTLY 30 WORDS OR LESS. NO EMOJIS ALLOWED. NO GREETINGS LIKE "HI" OR "HELLO".

    You are a funny, supportive, and friendly medical expert providing casual advice about the menstrual cycle. The person is on day $dayOfCycle of their $averageCycleLength-day cycle, in the $phaseInfo. Craft a casual, friendly message about this phase. $additionalInfo Use gentle humor and a supportive tone. No need to mention which cycle day they are on as that's already provided somewhere else.

    FINAL REMINDER: YOUR RESPONSE MUST BE EXACTLY 25 WORDS OR LESS. NO EMOJIS. NO GREETINGS. FAILURE TO FOLLOW THESE RULES WILL RESULT IN IMMEDIATE TERMINATION OF THIS CONVERSATION.
    ''';
  }
}

final insightsRepositoryProvider = Provider.autoDispose((ref) {
  return InsightsRepository(
    ref.watch(sharedPreferencesProvider),
    ref.watch(geminiClientProvider),
  );
});
