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
import 'package:intl/intl.dart';

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

  late final _dateFormatter = DateFormat('yyyy-MM-dd');

  static const _defaultPeriodDaysLength = 5;
  static const _defaultCycleDaysLength = 28;

  // Cache keys generated here: http://bit.ly/random-strings-generator
  static const _eventsStorageKey = 'nz8mgeG9Mrkh';
  static const _apiPredictionStorageKey = 'wBC2Dv3LBdAU';

  Future<Forecast> createForecastForDateFromEvents(
    DateTime selectedDate,
    List<CycleEvent> events,
  ) async {
    events.sort((a, b) => a.date.compareTo(b.date));

    final endDate = selectedDate.add(const Duration(days: 365));
    final apiPrediction = await _fetchFromApi(events);
    final averageCycleLength = apiPrediction.averageCycleLength;
    final averagePeriodLength = apiPrediction.averagePeriodLength;

    final predictions = _generatePredictions(
      selectedDate,
      events,
      apiPrediction.predictedCycleStarts,
      endDate,
      averageCycleLength,
      averagePeriodLength,
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
                  selectedDate.difference(e.date).inDays < averagePeriodLength,
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
      averagePeriodLength,
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
      averageCycleLength: averageCycleLength,
      averagePeriodLength: averagePeriodLength,
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

    try {
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
        predictedCycleStarts: predictions[0],
        averageCycleLength: predictions[1],
        averagePeriodLength: predictions[2],
      );

      await _saveToCache(periodEvents, apiPrediction);

      return apiPrediction;
    } catch (_) {
      rethrow; // TODO: Handle error
    }
  }

  Future<List<dynamic>> _fetchPredictions(String requestId) async {
    final predictedCycleStarts = await _cycleApiClient
        .get('/get_data/$requestId/predicted_cycle_starts');
    final averageCycleLength =
        await _cycleApiClient.get('/get_data/$requestId/average_cycle_length');
    final averagePeriodLength =
        await _cycleApiClient.get('/get_data/$requestId/average_period_length');

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
      predictedCycleStartsData
          .map((e) => _dateFormatter.parse(e as String))
          .toList(),
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
      'period_length': currentGroup.last.date
                  .difference(currentGroup.first.date)
                  .inDays <
              _defaultPeriodDaysLength
          ? _defaultPeriodDaysLength
          : currentGroup.last.date.difference(currentGroup.first.date).inDays,
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

    // Adjust predictions if period is late
    var adjustedPredictedStarts = List<DateTime>.from(predictedCycleStarts);

    if (selectedDate.isAfterToday) {
      final firstMissedPrediction =
          predictedCycleStarts.where((date) => date.isBefore(date)).lastOrNull;

      if (firstMissedPrediction != null &&
          firstMissedPrediction.isAfter(lastActualPeriod)) {
        // If we have a missed prediction, shift all future predictions
        final daysToShift =
            selectedDate.difference(firstMissedPrediction).inDays;
        adjustedPredictedStarts = predictedCycleStarts.map((date) {
          if (date.isAfter(lastActualPeriod)) {
            return date.add(Duration(days: daysToShift));
          }
          return date;
        }).toList();
      }
    }

    if (lastActualPeriod.isToday) {
      final fiveDaysAgo =
          lastActualPeriod.subtract(Duration(days: averagePeriodLength));
      final pastPeriodEvents = events
          .where(
            (e) =>
                e.type == CycleEventType.period &&
                !e.isPrediction &&
                e.date.isAfter(fiveDaysAgo),
          )
          .toList();

      final periodDaysToCreate = averagePeriodLength - pastPeriodEvents.length;

      if (periodDaysToCreate > 0) {
        for (int i = 1; i <= periodDaysToCreate; i++) {
          final date = lastActualPeriod.withoutTime().add(Duration(days: i));
          predictions.add(
            CycleEvent(
              date: date,
              type: CycleEventType.period,
              createdBy: _env.systemId,
            ),
          );
        }
      }
    }

    // Generate period predictions for future cycles using adjusted dates
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

    // Generate fertile windows
    final periodEvents = [...events, ...predictions]
        .where(
          (e) => e.type == CycleEventType.period && e.date.isBefore(endDate),
        )
        .toSet()
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (periodEvents.isEmpty) return predictions;

    // Start from the first recorded period
    for (int i = 0; i < periodEvents.length - 1; i++) {
      final currentPeriod = periodEvents[i].date;
      final nextPeriod = periodEvents[i + 1].date;

      // Calculate cycle length between current and next period
      final cycleLength = nextPeriod.difference(currentPeriod).inDays;

      // Use this cycle length to generate fertile window
      final fertilePeriodPredictions =
          _generateFertileWindow(currentPeriod, cycleLength, endDate);

      // Only add unique predictions before end date
      predictions.addAll(
        fertilePeriodPredictions.where(
          (prediction) =>
              prediction.date.isBefore(endDate) &&
              !predictions.any((existing) => existing.date == prediction.date),
        ),
      );
    }

    // Generate fertile window for the last recorded period
    final lastPeriod = periodEvents.last.date;

    final lastFertilePredictions =
        _generateFertileWindow(lastPeriod, averageCycleLength, endDate);

    predictions.addAll(
      lastFertilePredictions.where(
        (prediction) =>
            prediction.date.isBefore(endDate) &&
            !predictions.any((existing) => existing.date == prediction.date),
      ),
    );

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

    if (previousPredictedStart != null) {
      final periodDaysToCreate =
          predictedStart.difference(previousPredictedStart).inDays -
              _defaultCycleDaysLength;

      if (periodDaysToCreate == 0) return periodEvents;

      final newPredictedStart =
          predictedStart.subtract(Duration(days: periodDaysToCreate));

      // TODO Improve this
      for (int i = 0; i <= periodDaysToCreate; i++) {
        final periodDate = newPredictedStart.add(Duration(days: i));
        periodEvents.add(
          CycleEvent(
            date: periodDate,
            type: CycleEventType.period,
            isPrediction: true,
            createdBy: _env.systemId,
            isUncertainPrediction: true,
          ),
        );
      }
    }

    return periodEvents;
  }

  List<CycleEvent> _generateFertileWindow(
    DateTime start,
    int averageCycleLength,
    DateTime endDate,
  ) {
    final fertileWindow = <CycleEvent>[];

    final fertileWindowStart =
        start.add(Duration(days: (averageCycleLength * 0.5).floor()));
    final fertileWindowLength =
        (averageCycleLength * 0.2).floor().clamp(0, 6); // Max 6 days

    var currentDate = fertileWindowStart;
    final fertileWindowEnd =
        fertileWindowStart.add(Duration(days: fertileWindowLength));

    while (currentDate.isBefore(fertileWindowEnd) &&
        currentDate.isBefore(endDate)) {
      fertileWindow.add(
        CycleEvent(
          date: currentDate,
          type: CycleEventType.fertile,
          isPrediction: true,
          createdBy: _env.systemId,
        ),
      );
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return fertileWindow;
  }

  List<CycleEvent> _mergePredictionsWithActualEvents(
    List<CycleEvent> actualEvents,
    List<CycleEvent> predictions,
  ) {
    final mergedEvents = [...actualEvents];

    for (final prediction in predictions) {
      if (!mergedEvents
          .any((e) => e.date == prediction.date && e.type == prediction.type)) {
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
