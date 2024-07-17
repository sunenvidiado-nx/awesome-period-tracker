import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'home_state.mapper.dart';

@MappableClass()
class HomeState with HomeStateMappable {
  final List<CycleEvent> cycleEvents;
  final DateTime selectedDate;
  final Exception? error;

  const HomeState({
    required this.cycleEvents,
    required this.selectedDate,
    this.error,
  });
}
