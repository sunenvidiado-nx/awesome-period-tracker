import 'dart:convert';

import 'package:awesome_period_tracker/config/environment/env.dart';
import 'package:awesome_period_tracker/domain/models/api_prediction.dart';
import 'package:awesome_period_tracker/domain/models/cycle_event.dart';
import 'package:awesome_period_tracker/domain/models/cycle_event_type.dart';
import 'package:awesome_period_tracker/domain/models/forecast.dart';
import 'package:awesome_period_tracker/domain/models/menstruation_phase.dart';
import 'package:awesome_period_tracker/domain/models/process_cycle_data_request.dart';
import 'package:awesome_period_tracker/utils/extensions/date_time_extensions.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@injectable
class ForecastService {
  ForecastService(
    this._env,
    this._secureStorage,
    @Named('cycle_api_client') this._cycleApiClient,
  );

  final Env _env;
  final FlutterSecureStorage _secureStorage;
  final Dio _cycleApiClient;

  static const _defaultPeriodDaysLength = 5;
  static const _defaultCycleDaysLength = 28;

  // Cache keys generated here: http://bit.ly/random-strings-generator
  static const _eventsStorageKey = 'nz8mgeG9Mrkh';
  static const _apiPredictionStorageKey = 'wTcgDv3LBdAU';

  Future<Forecast> createForecastForDateFromEvents(
    DateTime selectedDate,
    List<CycleEvent> events,
  ) async {
    events.sort((a, b) => a.date.compareTo(b.date));

    final endDate = selectedDate.add(const Duration(days: 365));
    final apiPrediction = await _fetchFromApi(events);

    final predictions = _generatePredictions(
      selectedDate,
      events,
      apiPrediction.predictedCycleStarts,
      endDate,
      apiPrediction.averageCycleLength,
      apiPrediction.averagePeriodLength,
    );

    final mergedEvents = _mergePredictionsWithActualEvents(events, predictions);

    final nextPeriod = mergedEvents.firstWhereOrNull(
      (e) => e.date.isAfter(selectedDate) && e.type == CycleEventType.period,
    );

    final isCurrentlyInPeriod = mergedEvents
        .where((e) => e.type == CycleEventType.period && !e.isPrediction)
        .any(
          (e) =>
              e.date.isSameDay(selectedDate) ||
              e.date.isBefore(selectedDate) &&
                  selectedDate.difference(e.date).inDays <
                      apiPrediction.averagePeriodLength,
        );

    final daysUntilNextPeriod = _calculateDaysUntilNextPeriod(
      isCurrentlyInPeriod,
      nextPeriod,
      selectedDate,
    );

    final eventToday =
        mergedEvents.firstWhereOrNull((e) => e.date.isSameDay(selectedDate));

    final hasPeriodBeenLoggedRecently = _hasPeriodBeenLoggedRecently(
      events,
      selectedDate,
      apiPrediction.averagePeriodLength,
    );

    final dayOfCycle = _getDayOfCurrentCycle(mergedEvents, selectedDate);

    final phase = _determineMenstruationPhase(
      dayOfCycle,
      daysUntilNextPeriod,
      hasPeriodBeenLoggedRecently,
      eventToday?.type == CycleEventType.fertile,
    );

    final eventsForDate =
        mergedEvents.where((e) => e.date.isSameDay(selectedDate)).toList();

    return Forecast(
      date: selectedDate,
      dayOfCycle: dayOfCycle,
      averageCycleLength: apiPrediction.averageCycleLength,
      averagePeriodLength: apiPrediction.averagePeriodLength,
      daysUntilNextPeriod: daysUntilNextPeriod,
      phase: phase,
      events: mergedEvents,
      eventsForDate: eventsForDate,
    );
  }

  int _calculateDaysUntilNextPeriod(
    bool isCurrentlyInPeriod,
    CycleEvent? nextPeriod,
    DateTime date,
  ) {
    return isCurrentlyInPeriod
        ? 0
        : (nextPeriod != null ? nextPeriod.date.difference(date).inDays : -1);
  }

  bool _hasPeriodBeenLoggedRecently(
    List<CycleEvent> events,
    DateTime date,
    int averagePeriodLength,
  ) {
    return events
        .where((e) => e.type == CycleEventType.period && !e.isPrediction)
        .any(
          (e) => e.date.difference(date).inDays.abs() <= averagePeriodLength,
        );
  }

  Future<ApiPrediction> _fetchFromApi(List<CycleEvent> events) async {
    final periodEvents = events
        .where((e) => e.type == CycleEventType.period)
        .sortedBy((e) => e.date);

    final cachedData = await _getFromCache(periodEvents);
    if (cachedData != null) return cachedData;

    final pastData = ProcessCycleDataRequest(
      currentDate: DateTime.now().toIso8601String().split('T')[0],
      pastCycleData: _getPastCycleDataFromEvents(periodEvents),
    );

    final response = await _cycleApiClient.post(
      '/process_cycle_data',
      data: pastData.toMap(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch predictions');
    }

    final requestId = response.data!['request_id'] as String;
    final predictions = await _fetchPredictions(requestId);

    final apiPrediction = ApiPrediction(
      predictedCycleStarts: predictions[0] as List<DateTime>,
      averageCycleLength: predictions[1] as int,
      averagePeriodLength: predictions[2] as int,
    );

    await _saveToCache(periodEvents, apiPrediction);

    return apiPrediction;
  }

  Future<List<dynamic>> _fetchPredictions(String requestId) async {
    final [
      predictedCycleStarts,
      averageCycleLength,
      averagePeriodLength,
    ] = await Future.wait([
      _cycleApiClient.get('/get_data/$requestId/predicted_cycle_starts'),
      _cycleApiClient.get('/get_data/$requestId/average_cycle_length'),
      _cycleApiClient.get('/get_data/$requestId/average_period_length'),
    ]);

    if (predictedCycleStarts.statusCode != 200 ||
        averageCycleLength.statusCode != 200 ||
        averagePeriodLength.statusCode != 200) {
      throw Exception('Failed to fetch predictions');
    }

    final predictedCycleStartsData =
        predictedCycleStarts.data!['predicted_cycle_starts'] as List;
    final averageCycleLengthData = double.parse(
      averageCycleLength.data!['average_cycle_length'] as String,
    ).round();
    final averagePeriodLengthData = double.parse(
      averagePeriodLength.data!['average_period_length'] as String,
    ).round();

    return [
      predictedCycleStartsData.map((e) => DateTime.parse(e as String)).toList(),
      averageCycleLengthData,
      averagePeriodLengthData,
    ];
  }

  List<Map> _getPastCycleDataFromEvents(
    List<CycleEvent> events,
  ) {
    if (events.isEmpty) return [];

    final result = <Map>[];
    List<CycleEvent> currentGroup = [events.first];

    // Group events that are within 10 days of each other
    for (int i = 1; i < events.length; i++) {
      final currentEvent = events[i];
      final firstEventInGroup = currentGroup.first;
      final daysSinceGroupStart =
          currentEvent.date.difference(firstEventInGroup.date).inDays;

      if (daysSinceGroupStart <= 10) {
        currentGroup.add(currentEvent);
      } else {
        result.add(_createCycleData(currentGroup));
        currentGroup = [currentEvent]; // Start new group
      }
    }

    // Add the first event of the last group
    if (currentGroup.isNotEmpty) {
      result.add(_createCycleData(currentGroup));
    }

    return result;
  }

  Map _createCycleData(List<CycleEvent> currentGroup) {
    return {
      'cycle_start_date':
          currentGroup.first.date.toIso8601String().split('T')[0],
      'period_length':
          currentGroup.last.date.difference(currentGroup.first.date).inDays,
    };
  }

  int _getDayOfCurrentCycle(List<CycleEvent> events, DateTime selectedDate) {
    if (events.isEmpty) return 1;

    final recentPeriods = events
        .where(
          (e) =>
              e.type == CycleEventType.period && !e.date.isAfter(selectedDate),
        )
        .toList();

    if (recentPeriods.isEmpty) return 1;

    late DateTime periodStart;

    recentPeriods.sort((a, b) => b.date.compareTo(a.date));

    for (final period in recentPeriods) {
      final index = recentPeriods.indexOf(period);
      final previousPeriod = recentPeriods[index + 1];

      if (period.date.difference(previousPeriod.date).inDays > 1) {
        periodStart = period.date;
        break;
      }
    }

    return selectedDate.difference(periodStart).inDays + 1;
  }

  List<CycleEvent> _generatePredictions(
    DateTime selectedDate,
    List<CycleEvent> events,
    List<DateTime> predictedCycleStarts,
    DateTime endDate,
    int averageCycleLength,
    int averagePeriodLength,
  ) {
    final predictions = <CycleEvent>[];

    // Find the last actual period
    final lastActualPeriod = events
            .where((e) => e.type == CycleEventType.period && !e.isPrediction)
            .map((e) => e.date)
            .lastOrNull ??
        selectedDate;

    // Adjust predictions if period might be late
    final adjustedPredictedStarts = _adjustPredictedStarts(
      selectedDate,
      lastActualPeriod,
      predictedCycleStarts,
    );

    // Generate period predictions for future cycles using adjusted dates
    predictions.addAll(
      _generateFuturePeriodPredictions(
        lastActualPeriod,
        adjustedPredictedStarts,
        endDate,
        averagePeriodLength,
      ),
    );

    // Generate fertile window predictions
    predictions.addAll(
      _generateFertileWindowPredictions([...events, ...predictions]),
    );

    return predictions;
  }

  List<CycleEvent> _generateFertileWindowPredictions(List<CycleEvent> events) {
    final periodFirstDates = _findPeriodStartDates(events);
    final fertileWindowEvents = <CycleEvent>[];

    // Require at least two period dates to predict fertile windows
    if (periodFirstDates.length < 2) return fertileWindowEvents;

    for (int i = 0; i < periodFirstDates.length - 1; i++) {
      final nextPeriodStart = periodFirstDates[i + 1];

      // Predict ovulation 14 days before next period
      final ovulationDate = nextPeriodStart.subtract(const Duration(days: 14));

      // Fertile window is 5 days before and day of ovulation
      final fertileWindowStart =
          ovulationDate.subtract(const Duration(days: 5));
      final fertileWindowEnd = ovulationDate;

      // Generate fertile window events
      var currentDate = fertileWindowStart;

      while (!currentDate.isAfter(fertileWindowEnd)) {
        fertileWindowEvents.add(
          CycleEvent(
            date: currentDate,
            type: CycleEventType.fertile,
            isPrediction: true,
            createdBy: _env.systemId,
          ),
        );
        currentDate = currentDate.add(const Duration(days: 1));
      }
    }

    return fertileWindowEvents;
  }

  List<DateTime> _findPeriodStartDates(List<CycleEvent> events) {
    // Sort and deduplicate event dates
    final mergedEvents = events
        .where(
          (e) => e.type == CycleEventType.period && !e.isUncertainPrediction,
        )
        .map((e) => e.date.withoutTime())
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b));

    final periodStartDates = <DateTime>[];

    // Start with first date
    periodStartDates.add(mergedEvents.first);

    for (int eventIndex = 1; eventIndex < mergedEvents.length; eventIndex++) {
      final currentDate = mergedEvents[eventIndex];
      final previousStartDate = periodStartDates.last;

      // Check for potential new cycle start
      final daysSincePreviousStart =
          currentDate.difference(previousStartDate).inDays;

      if (daysSincePreviousStart > (_defaultCycleDaysLength)) {
        // Validate if this is truly a new cycle
        bool isNewCycle = true;

        for (int prevEventIndex = eventIndex - 1;
            prevEventIndex >= 0;
            prevEventIndex--) {
          final previousDate = mergedEvents[prevEventIndex];
          final daysFromPrevious = currentDate.difference(previousDate).inDays;

          if (daysFromPrevious <= _defaultPeriodDaysLength) {
            isNewCycle = false;
            break;
          }

          if (daysFromPrevious > (_defaultCycleDaysLength)) break;
        }

        if (isNewCycle) periodStartDates.add(currentDate);
      }
    }

    return periodStartDates;
  }

  List<DateTime> _adjustPredictedStarts(
    DateTime selectedDate,
    DateTime lastActualPeriod,
    List<DateTime> predictedCycleStarts,
  ) {
    if (!selectedDate.isAfterToday) return predictedCycleStarts;

    final firstMissedPrediction =
        predictedCycleStarts.where((date) => date.isBefore(date)).lastOrNull;

    if (firstMissedPrediction == null ||
        !firstMissedPrediction.isAfter(lastActualPeriod)) {
      return predictedCycleStarts;
    }

    // If we have a missed prediction, shift all future predictions
    final daysToShift = selectedDate.difference(firstMissedPrediction).inDays;
    return predictedCycleStarts
        .map(
          (date) => date.isAfter(lastActualPeriod)
              ? date.add(Duration(days: daysToShift))
              : date,
        )
        .toList();
  }

  List<CycleEvent> _generateFuturePeriodPredictions(
    DateTime lastActualPeriod,
    List<DateTime> adjustedPredictedStarts,
    DateTime endDate,
    int averagePeriodLength,
  ) {
    final predictions = <CycleEvent>[];

    for (final predictedStart in adjustedPredictedStarts) {
      if (predictedStart.isAfter(lastActualPeriod) &&
          predictedStart.isBefore(endDate)) {
        final previousPredictedStart = adjustedPredictedStarts
            .where((date) => date.isBefore(predictedStart))
            .lastOrNull;

        predictions.addAll(
          _generatePeriodEvents(
            predictedStart,
            averagePeriodLength,
            previousPredictedStart,
          ),
        );
      }
    }

    return predictions;
  }

  List<CycleEvent> _generatePeriodEvents(
    DateTime predictedStart,
    int averagePeriodLength,
    DateTime? previousPredictedStart,
  ) {
    final periodEvents = <CycleEvent>[];

    for (var i = 0; i < averagePeriodLength; i++) {
      final periodDate = predictedStart.add(Duration(days: i));
      periodEvents.add(
        CycleEvent(
          date: periodDate,
          type: CycleEventType.period,
          isPrediction: true,
          createdBy: _env.systemId,
        ),
      );
    }

    return periodEvents;
  }

  List<CycleEvent> _mergePredictionsWithActualEvents(
    List<CycleEvent> actualEvents,
    List<CycleEvent> predictions,
  ) {
    final mergedEvents = [...actualEvents];

    for (final prediction in predictions) {
      if (!mergedEvents.any(
        (e) =>
            e.date == prediction.date &&
            e.type == prediction.type &&
            e.isPrediction == prediction.isPrediction,
      )) {
        mergedEvents.add(prediction);
      }
    }

    return mergedEvents..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> _saveToCache(
    List<CycleEvent> events,
    ApiPrediction apiPrediction,
  ) async {
    final eventsJson = jsonEncode(events.map((e) => e.toJson()).toList());

    await Future.wait([
      _secureStorage.write(key: _eventsStorageKey, value: eventsJson),
      _secureStorage.write(
        key: _apiPredictionStorageKey,
        value: apiPrediction.toJson(),
      ),
    ]);
  }

  Future<ApiPrediction?> _getFromCache(List<CycleEvent> currentEvents) async {
    final cachedEventsJson = await _secureStorage.read(key: _eventsStorageKey);
    final cachedApiResponseJson =
        await _secureStorage.read(key: _apiPredictionStorageKey);

    if (cachedEventsJson == null || cachedApiResponseJson == null) return null;

    try {
      final currentEventsJson =
          jsonEncode(currentEvents.map((e) => e.toJson()).toList());

      if (currentEventsJson != cachedEventsJson) return null;

      return ApiPredictionMapper.fromJson(cachedApiResponseJson);
    } catch (e) {
      return null;
    }
  }

  MenstruationPhase _determineMenstruationPhase(
    int dayOfCycle,
    int daysUntilNextPeriod,
    bool hasPeriodBeenLoggedRecently,
    bool isFertile,
  ) {
    if (isFertile) return MenstruationPhase.ovulation;
    if (hasPeriodBeenLoggedRecently) return MenstruationPhase.menstruation;

    if (daysUntilNextPeriod >= 0 && daysUntilNextPeriod <= 2) {
      return MenstruationPhase.luteal;
    }

    final percentageUntilNextPeriod = (daysUntilNextPeriod / dayOfCycle) * 100;
    if (percentageUntilNextPeriod >= 75) return MenstruationPhase.follicular;
    if (percentageUntilNextPeriod >= 50) return MenstruationPhase.ovulation;

    return MenstruationPhase.luteal;
  }
}
