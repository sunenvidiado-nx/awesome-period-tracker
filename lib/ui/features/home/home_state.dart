part of 'home_state_manager.dart';

@MappableClass()
class HomeState with HomeStateMappable {
  const HomeState({
    required this.selectedDate,
    required this.isLoading,
    this.forecast,
    this.insight,
  });

  factory HomeState.initial() => HomeState(
        isLoading: false,
        selectedDate: DateTime.now().withoutTime(),
      );

  final Forecast? forecast;
  final Insight? insight;
  final DateTime selectedDate;
  final bool isLoading;
}
