import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'log_cycle_event_state.mapper.dart';

@MappableClass()
class LogCycleEventState with LogCycleEventStateMappable {
  final DateTime selectedDate;
  final CycleEventType? selectedCycleEventType;
  final Exception? error;

  const LogCycleEventState({
    required this.selectedDate,
    this.selectedCycleEventType,
    this.error,
  });
}
