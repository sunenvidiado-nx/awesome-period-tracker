import 'package:awesome_period_tracker/core/extensions/date_time_extensions.dart';
import 'package:awesome_period_tracker/core/extensions/string_extensions.dart';
import 'package:awesome_period_tracker/core/infrastructure/gemini_client.dart';
import 'package:awesome_period_tracker/features/home/domain/forecast.dart';
import 'package:awesome_period_tracker/features/home/domain/insight.dart';
import 'package:awesome_period_tracker/features/home/domain/menstruation_phase.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

@injectable
class AiInsightsService {
  const AiInsightsService(
    this._sharedPreferences,
    this._geminiClient,
  );

  final SharedPreferences _sharedPreferences;
  final GeminiClient _geminiClient;

  Future<Insight> getInsightForForecast({
    required Forecast forecast,
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
CRITICAL INSTRUCTIONS - READ CAREFULLY:

1. RESPONSE MUST BE EXACTLY 50 WORDS OR LESS.
2. USE MARKDOWN LIST FORMAT WITH 2-3 BULLET POINTS.
3. NO EMOJIS, GREETINGS, OR EMOJI-LIKE TEXT (e.g., :wink:).
4. USE A FRIENDLY, SUPPORTIVE, AND GENTLY HUMOROUS TONE.
5. FOLLOW THIS EXACT FORMAT:

- [Point 1 about the phase, supportive tone]
- [Point 2 with additional info, friendly advice]
- (Optional) [Point 3 with more info and gentle humor]

Context: $timeContext menstrual cycle, day $dayOfCycle of $averageCycleLength-day cycle, $phaseInfo.
Include: $summaryOrAdvice, $additionalInfo. Don't mention cycle day.

MAINTAIN A SUPPORTIVE MEDICAL EXPERT PERSONA THROUGHOUT.

FAILURE TO FOLLOW THESE RULES WILL RESULT IN IMMEDIATE REJECTION.
''';
  }
}
