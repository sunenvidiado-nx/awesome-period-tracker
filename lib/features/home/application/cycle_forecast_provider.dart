import 'package:awesome_period_tracker/features/home/data/cycle_events_repository.dart';
import 'package:awesome_period_tracker/features/home/data/cycle_forecast_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cycleForecastProvider = FutureProvider.autoDispose((ref) async {
  final events = await ref.read(cycleEventsRepositoryProvider).get();

  return ref
      .read(cyclePredictionsRepositoryProvider)
      .createForecastForEvents(events);
});
