part of 'home_state_manager.dart';

class HomeState {
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

  HomeState copyWith({
    Forecast? forecast,
    Insight? insight,
    DateTime? selectedDate,
    bool? isLoading,
    bool? shouldCreateUserPartnership,
  }) {
    return HomeState(
      forecast: forecast ?? this.forecast,
      insight: insight ?? this.insight,
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is HomeState &&
          runtimeType == other.runtimeType &&
          selectedDate == other.selectedDate &&
          isLoading == other.isLoading &&
          forecast == other.forecast &&
          insight == other.insight;

  @override
  int get hashCode =>
      selectedDate.hashCode ^
      isLoading.hashCode ^
      forecast.hashCode ^
      insight.hashCode;
}
