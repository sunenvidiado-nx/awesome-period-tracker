import 'package:dart_mappable/dart_mappable.dart';

part 'api_prediction.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class ApiPrediction with ApiPredictionMappable {
  const ApiPrediction({
    required this.predictedCycleStarts,
    required this.averageCycleLength,
    required this.averagePeriodLength,
  });

  final List<DateTime> predictedCycleStarts;
  final int averageCycleLength;
  final int averagePeriodLength;
}
