part of 'home_state_manager.dart';

@MappableClass()
class HomeState with HomeStateMappable {
  const HomeState({
    required this.selectedDate,
    required this.isLoading,
    this.forecast,
    this.insight,
    this.error,
  });

  factory HomeState.initial() {
    return HomeState(
      isLoading: false,
      selectedDate: DateTime.now().withoutTime(),
    );
  }

  final DateTime selectedDate;
  final bool isLoading;
  final Forecast? forecast;
  final Insight? insight;
  final Exception? error;
}
