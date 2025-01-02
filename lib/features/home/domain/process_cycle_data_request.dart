import 'package:dart_mappable/dart_mappable.dart';

part 'process_cycle_data_request.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class ProcessCycleDataRequest with ProcessCycleDataRequestMappable {
  const ProcessCycleDataRequest({
    required this.currentDate,
    required this.pastCycleData,
    this.maxCyclePredictions = 10,
  });

  final String currentDate;
  final List<Map> pastCycleData;
  final int maxCyclePredictions;
}
