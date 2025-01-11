import 'package:awesome_period_tracker/config/clients/gemini_client.dart';
import 'package:awesome_period_tracker/domain/models/forecast.dart';
import 'package:awesome_period_tracker/domain/models/insight.dart';
import 'package:awesome_period_tracker/domain/models/menstruation_phase.dart';
import 'package:awesome_period_tracker/utils/extensions/date_time_extensions.dart';
import 'package:awesome_period_tracker/utils/extensions/string_extensions.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:table_calendar/table_calendar.dart';

@injectable
class AiInsightsService {
  const AiInsightsService(
    this._secureStorage,
    this._geminiClient,
  );

  final FlutterSecureStorage _secureStorage;
  final GeminiClient _geminiClient;

  // Cache keys generated here: http://bit.ly/random-strings-generator
  static const _insightStorageKeyPrefix = 'd5flbx32awBNM_';

  Future<Insight> getInsightForForecast(
    Forecast forecast, {
    bool useCache = true,
    bool isPast = false,
  }) async {
    final prefsKey = '$_insightStorageKeyPrefix${forecast.date.toYmdString()}';

    try {
      if (await _secureStorage.containsKey(key: prefsKey) && useCache) {
        final cachedInsight =
            InsightMapper.fromJson((await _secureStorage.read(key: prefsKey))!);

        final isCacheValid =
            isSameDay(cachedInsight.date, forecast.date.toUtc());

        if (isCacheValid) return cachedInsight;
      }
    } catch (_) {
      // On exceptions, do nothing and generate new insight.
      // This is to prevent app crashes due to corrupted cache data.
    }

    final geminiInsight = await _generateInsights(
      forecast.dayOfCycle,
      forecast.averageCycleLength,
      forecast.phase,
      isPast,
    );

    final insight = Insight(
      insights: geminiInsight.removeEmojis().removeDoubleSpaces(),
      date: forecast.date.toUtc(),
      isPast: isPast,
    );

    await _secureStorage.write(key: prefsKey, value: insight.toJson());

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
        additionalInfo = isPast
            ? 'Mention energy levels and mood changes experienced. Add an encouraging note about the body\'s natural renewal.'
            : 'Share tips for harnessing increased energy. Add a light-hearted comment about feeling refreshed.';
        break;
      case MenstruationPhase.ovulation:
        phaseInfo = 'ovulation phase';
        additionalInfo = isPast
            ? 'Discuss peak fertility signs experienced. Include a playful note about heightened confidence or charm.'
            : 'Highlight fertility window and energy peaks. Add a fun comment about feeling extra magnetic/freaky today.';
        break;
      case MenstruationPhase.luteal:
        phaseInfo = 'luteal phase';
        if (dayOfCycle > averageCycleLength) {
          additionalInfo = isPast
              ? 'Describe late period symptoms experienced. Add a gentle reminder about cycle variations being normal.'
              : 'Address common late period concerns. Include a light joke about being fashionably late.';
        } else {
          additionalInfo = isPast
              ? 'Reflect on premenstrual changes experienced. Share a relatable observation about this phase.'
              : 'Prepare for upcoming premenstrual changes. Add a gentle reminder about self-care with a touch of humor.';
        }
        break;
      case MenstruationPhase.menstruation:
        phaseInfo = 'menstruation phase';
        additionalInfo = isPast
            ? 'Acknowledge period experiences. Share a supportive note with a touch of period humor.'
            : 'Suggest comfort measures and self-care tips. Add an empathetic joke about period challenges.';
        break;
    }

    final timeContext = isPast ? 'past' : 'upcoming';
    final summaryOrAdvice = isPast
        ? 'Share insights about what likely happened'
        : 'Provide friendly advice and useful tips';

    return '''
CRITICAL INSTRUCTIONS:

1. RESPONSE MUST BE EXACTLY 50 WORDS OR LESS.
2. USE MARKDOWN LIST FORMAT WITH 2-3 BULLET POINTS.
3. NO EMOJIS, GREETINGS, OR EMOJI-LIKE TEXT (e.g., :wink:).
4. USE A FRIENDLY, SUPPORTIVE, AND GENTLY HUMOROUS TONE.
5. FOLLOW THIS EXACT FORMAT:

- [Point 1: Main phase insight with supportive tone]
- [Point 2: Practical advice or reflection]
- (Optional) [Point 3: Uplifting or humorous observation]

Context: $timeContext menstrual cycle, day $dayOfCycle of $averageCycleLength-day cycle, $phaseInfo.
Include: $summaryOrAdvice, $additionalInfo. Don't mention cycle day numbers.

MAINTAIN A SUPPORTIVE MEDICAL EXPERT PERSONA THROUGHOUT.
''';
  }
}
