import 'dart:convert';

import 'package:awesome_period_tracker/config/di_keys.dart';
import 'package:awesome_period_tracker/domain/models/api_prediction.dart';
import 'package:awesome_period_tracker/domain/models/cycle_event.dart';
import 'package:awesome_period_tracker/domain/models/cycle_event_type.dart';
import 'package:awesome_period_tracker/domain/models/process_cycle_data_request.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@injectable
class CycleDataRepository {
  const CycleDataRepository(
    this._secureStorage,
    @Named(DiKeys.cycleApiClientKey) this._cycleApiClient,
  );

  final FlutterSecureStorage _secureStorage;
  final Dio _cycleApiClient;

  // Cache keys generated here: http://bit.ly/random-strings-generator
  static const _eventsStorageKey = 'nz8mgeG9Mrkh';
  static const _apiPredictionStorageKey = 'wTcgDv3LBdAU';

  Future<ApiPrediction> fetchPrediction(List<CycleEvent> events) async {
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
    final [predictedCycleStarts, averageCycleLength, averagePeriodLength] =
        await Future.wait([
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

  List<Map> _getPastCycleDataFromEvents(List<CycleEvent> events) {
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
          // If the period is less than 5 days, set it to 5 days to avoid errors
          currentGroup.last.date.difference(currentGroup.first.date).inDays < 5
              ? 5
              : currentGroup.last.date
                  .difference(currentGroup.first.date)
                  .inDays,
    };
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
}
