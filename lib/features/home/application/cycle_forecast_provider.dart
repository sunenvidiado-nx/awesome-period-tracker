import 'package:awesome_period_tracker/features/home/data/cycle_events_repository.dart';
import 'package:awesome_period_tracker/features/home/data/cycle_forecast_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cycleForecastProvider =
    FutureProvider.family.autoDispose((ref, DateTime date) async {
  final events = await ref.read(cycleEventsRepositoryProvider).get();

  return ref
      .read(cycleForecastRepositoryProvider)
      .createForecastForDateFromEvents(events: events, date: date);
});
