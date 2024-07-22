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
  final String dayOfCycle;
  final String daysUntilNextPeriod;
  final String insights;
}
