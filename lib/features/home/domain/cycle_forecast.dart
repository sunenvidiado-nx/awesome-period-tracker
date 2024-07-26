import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/home/domain/menstruation_phase.dart';

class CycleForecast {
  const CycleForecast({
    required this.date,
    required this.dayOfCycle,
    required this.daysUntilNextPeriod,
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.averageFertilityWindowLength,
    required this.phase,
    required this.events,
  });

  final DateTime date;
  final int dayOfCycle;
  final int daysUntilNextPeriod;
  final int averageCycleLength;
  final int averagePeriodLength;
  final int averageFertilityWindowLength;
  final MenstruationPhase phase;
  final List<CycleEvent> events;
}