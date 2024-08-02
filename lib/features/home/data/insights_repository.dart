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

        final isCacheValid =
            isSameDay(cachedInsight.date, forecast.date.toUtc());

        if (isCacheValid) return cachedInsight;
      }
    } catch (e) {
      // On exceptions, do nothing and generate new a new insight.
      // This is to prevent app crashes due to corrupted cache data.
    }

    const isPast = false; // TODO Make this dymaic

    final geminiInsight = await _generateInsights(
      forecast.dayOfCycle,
      forecast.averageCycleLength,
      forecast.phase,
      isPast,
    );

    final insight = Insight(
      insights: geminiInsight.removeEmojis(),
      date: forecast.date.toUtc(),
      isPast: isPast,
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
            'Give expectations for coming days. Add a light-hearted comment about renewed energy or optimism.';
        break;
      case MenstruationPhase.ovulation:
        phaseInfo = 'ovulation phase';
        additionalInfo =
            'Discuss fertility peaks. Include a playful remark about feeling "frisky/freaky" or extra energetic.';
        break;
      case MenstruationPhase.luteal:
        phaseInfo = 'luteal phase';
        if (dayOfCycle > averageCycleLength) {
          additionalInfo =
              'Mention common premenstrual symptoms. Note the period is late but it\'s normal. You may add a light joke about being fashionably late.';
        } else {
          additionalInfo =
              'Discuss common premenstrual symptoms. Share an interesting fact about this phase with a gentle joke.';
        }
        break;
      case MenstruationPhase.menstruation:
        phaseInfo = 'menstruation phase';
        additionalInfo =
            'Encourage self-care and symptom management. Add a witty, relatable joke about periods.';
        break;
    }

    final timeContext = isPast ? 'previous' : 'current';
    final summaryOrAdvice = isPast
        ? 'Summarize likely experiences'
        : 'Provide friendly advice and useful insights';

    return '''
CRITICAL INSTRUCTIONS: YOUR RESPONSE MUST BE EXACTLY 50 WORDS OR LESS. NO EMOJIS OR GREETINGS ALLOWED.

You are a supportive medical expert discussing a $timeContext menstrual cycle. The person ${isPast ? 'was' : 'is'} on day $dayOfCycle of a $averageCycleLength-day cycle, in the $phaseInfo.

$summaryOrAdvice about this phase. $additionalInfo Use gentle humor and a supportive tone. Don't mention the cycle day.

CRUCIAL FORMAT REQUIREMENT: YOUR RESPONSE MUST BE IN MARKDOWN FORMAT AS A LIST WITH 2-3 BULLET POINTS. USE '-' FOR BULLET POINTS.

Example format:
- Point 1 about the phase
- Point 2 with additional info (like symptoms, what to expect for coming days, etc.)
- (Optional) Point 3 with more additional info and a gentle joke

FINAL REMINDERS: 
1. EXACTLY 50 WORDS OR LESS
2. MARKDOWN LIST FORMAT WITH 2-3 POINTS
3. NO EMOJIS OR GREETINGS
4. FAILURE TO FOLLOW THESE RULES WILL RESULT IN REJECTION OF THE RESPONSE
''';
  }
}

final insightsRepositoryProvider = Provider.autoDispose((ref) {
  return InsightsRepository(
    ref.watch(sharedPreferencesProvider),
    ref.watch(geminiClientProvider),
  );
});
