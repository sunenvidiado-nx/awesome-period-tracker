import 'package:dart_mappable/dart_mappable.dart';

part 'insight.mapper.dart';

@MappableClass()
class Insight with InsightMappable {
  const Insight({
    required this.date,
    required this.insights,
    required this.isPast,
  });

  final DateTime date;
  final String insights;
  final bool isPast;
}
