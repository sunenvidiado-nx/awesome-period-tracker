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

  // Cache keys generated here: http://bit.ly/random-strings-generator
  static const _eventsStorageKey = 'nz8mgeU9Mrkh';
  static const _apiResponseStorageKey = 'wBC2Dv3KBdAU';

  Future<Forecast> createForecastForDateFromEvents(
    DateTime selectedDate,
    List<CycleEvent> events,
  ) async {
    events.sort((a, b) => a.date.compareTo(b.date));

    final endDate = selectedDate.add(const Duration(days: 365));
    final dayOfCycle = _getDayOfCurrentCycle(events, selectedDate);
    final apiPrediction = await _fetchFromApi(events);
    final averageCycleLength = apiPrediction.averageCycleLength;
    final averagePeriodLength = apiPrediction.averagePeriodLength;

    final predictions = _generatePredictions(
      selectedDate,
      events,
      apiPrediction.predictedCycleStarts,
      selectedDate,
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
      'period_length':
          currentGroup.last.date.difference(currentGroup.first.date).inDays,
    };
  }

  int _getDayOfCurrentCycle(List<CycleEvent> events, DateTime now) {
    if (events.isEmpty) return 1;

    final recentPeriods = events
        .where(
          (e) =>
              e.type == CycleEventType.period &&
              !e.isPrediction &&
              !e.date.isAfter(now),
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

    return now.difference(periodStart).inDays + 1;
  }

  List<DateTime> _getAdjustedPredictedStarts(
    DateTime selectedDate,
    List<CycleEvent> events,
    List<DateTime> predictedCycleStarts,
  ) {
    if (predictedCycleStarts.isEmpty) return [];

    final lastActualPeriod = events
        .where((e) => e.type == CycleEventType.period && !e.isPrediction)
        .sortedBy((e) => e.date)
        .last
        .date;

    // If no late period, return original predictions
    if (!predictedCycleStarts.first.isBefore(selectedDate)) {
      return predictedCycleStarts;
    }

    // Handle late period
    final firstMissedPrediction = predictedCycleStarts
        .where((date) => date.isBefore(selectedDate))
        .lastOrNull;

    if (firstMissedPrediction == null ||
        !firstMissedPrediction.isAfter(lastActualPeriod)) {
      return predictedCycleStarts;
    }

    final daysToShift = selectedDate.difference(firstMissedPrediction).inDays;
    return predictedCycleStarts.map((date) {
      if (date.isAfter(lastActualPeriod)) {
        return date.add(Duration(days: daysToShift));
      }
      return date;
    }).toList();
  }

  List<CycleEvent> _getPastPeriodsInRange(
    List<CycleEvent> events,
    DateTime startDate,
    DateTime endDate,
    int averageCycleLength,
  ) {
    return events
        .where(
          (e) =>
              e.type == CycleEventType.period &&
              !e.isPrediction &&
              e.date.isAfter(
                startDate.subtract(Duration(days: averageCycleLength)),
              ) &&
              e.date.isBefore(endDate),
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<CycleEvent> _generatePredictions(
    DateTime selectedDate,
    List<CycleEvent> events,
    List<DateTime> predictedCycleStarts,
    DateTime startDate,
    DateTime endDate,
    int averageCycleLength,
    int averagePeriodLength,
  ) {
    final predictions = <CycleEvent>[];
    final adjustedPredictedStarts = _getAdjustedPredictedStarts(
      selectedDate,
      events,
      predictedCycleStarts,
    );

    // Generate predictions for future cycles
    for (final predictedStart in adjustedPredictedStarts) {
      if (predictedStart.isAfter(startDate) &&
          predictedStart.isBefore(endDate)) {
        predictions.addAll([
          ..._generatePeriodEvents(
              predictedStart, averagePeriodLength, endDate),
          ..._generateFertileWindow(
              predictedStart, averageCycleLength, endDate),
        ]);
      }
    }

    // Handle past periods
    final pastPeriods = _getPastPeriodsInRange(
      events,
      startDate,
      endDate,
      averageCycleLength,
    );

    final periodStarts = _groupPeriodStarts(pastPeriods, averagePeriodLength);

    // Generate fertile windows for past periods
    for (final periodStart in periodStarts) {
      predictions.addAll(
        _generateFertileWindow(
          periodStart,
          averageCycleLength,
          endDate,
        ),
      );
    }

    // Handle current period fertile window if needed
    final lastActualPeriod = events
        .where((e) => e.type == CycleEventType.period && !e.isPrediction)
        .sortedBy((e) => e.date)
        .last
        .date;

    if (!periodStarts.contains(lastActualPeriod)) {
      predictions.addAll(
        _generateFertileWindow(
          lastActualPeriod,
          averageCycleLength,
          endDate,
        ),
      );
    }

    return predictions;
  }

  List<CycleEvent> _generatePeriodEvents(
    DateTime predictedStart,
    int averagePeriodLength,
    DateTime endDate,
  ) {
    final periodEvents = <CycleEvent>[];

    for (var i = 0; i < averagePeriodLength; i++) {
      final periodDate = predictedStart.add(Duration(days: i));
      if (periodDate.isBefore(endDate)) {
        periodEvents.add(
          CycleEvent(
            date: periodDate,
            type: CycleEventType.period,
            isPrediction: true,
            createdBy: _env.systemId,
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

  List<DateTime> _groupPeriodStarts(
    List<CycleEvent> pastPeriods,
    int averagePeriodLength,
  ) {
    final periodStarts = <DateTime>[];
    if (pastPeriods.isNotEmpty) {
      var currentGroup = [pastPeriods.first];
      for (var i = 1; i < pastPeriods.length; i++) {
        if (pastPeriods[i].date.difference(currentGroup.first.date).inDays >
            averagePeriodLength) {
          periodStarts.add(currentGroup.first.date);
          currentGroup = [pastPeriods[i]];
        } else {
          currentGroup.add(pastPeriods[i]);
        }
      }
      if (currentGroup.isNotEmpty) {
        periodStarts.add(currentGroup.first.date);
      }
    }
    return periodStarts;
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
    final eventsJson = jsonEncode(events.map((e) => e.toMap()).toList());

    await Future.wait([
      _secureStorage.write(key: _eventsStorageKey, value: eventsJson),
      _secureStorage.write(
        key: _apiResponseStorageKey,
        value: apiPrediction.toJson(),
      ),
    ]);
  }

  Future<ApiPrediction?> _getFromCache(List<CycleEvent> currentEvents) async {
    try {
      final cachedEventsJson =
          await _secureStorage.read(key: _eventsStorageKey);

      final currentEventsJson =
          jsonEncode(currentEvents.map((e) => e.toMap()).toList());

      if (cachedEventsJson != currentEventsJson) {
        return null;
      }

      return ApiPredictionMapper.fromJson(
        await _secureStorage.read(key: _apiResponseStorageKey) as String,
      );
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
