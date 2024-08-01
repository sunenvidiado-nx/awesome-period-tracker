import 'package:awesome_period_tracker/features/home/application/cycle_forecast_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

final cycleEventsForDateProvider =
    FutureProvider.family.autoDispose((ref, DateTime date) async {
  final forecast = await ref.watch(cycleForecastProvider(date).future);

  return forecast.events.where((event) => isSameDay(event.date, date)).toList();
});
