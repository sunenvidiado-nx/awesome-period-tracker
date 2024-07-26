import 'package:dart_mappable/dart_mappable.dart';

part 'insight.mapper.dart';

@MappableClass()
class Insight with InsightMappable {
  const Insight({
    required this.date,
    required this.dayOfCycle,
    required this.daysUntilNextPeriod,
    required this.insights,
  });

  final DateTime date;
  final int dayOfCycle;
  final int daysUntilNextPeriod;
  final String insights;

  String get dayOfCycleMessage {
    if (dayOfCycle == -1) return 'No cycle data available';
    if (dayOfCycle == -2) return 'Most recent event is future';
    if (dayOfCycle == 1) return 'Day 1 of period';

    return 'Day $dayOfCycle of cycle';
  }

  String get daysUntilNextPeriodMessage {
    if (daysUntilNextPeriod == -69) return 'No data to predict period';
    if (daysUntilNextPeriod < 1) return 'Period may be delayed';
    if (daysUntilNextPeriod == 0) return 'Period may start today';
    if (daysUntilNextPeriod == 1) return 'Period may start tomorrow';

    return '$daysUntilNextPeriod days until next period';
  }
}
