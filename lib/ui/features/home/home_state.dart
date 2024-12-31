part of 'home_state_manager.dart';

@freezed
sealed class HomeState with _$HomeState {
  const factory HomeState.loading() = LoadingHomeState;
  const factory HomeState.error([String? message]) = ErrorHomeState;
  const factory HomeState.data({
    required List<CycleEvent> events,
    required DateTime selectedDate,
    required String userName,
    required bool lowChanceOfPregnancy,
    required CyclePhase cyclePhase,
    required DateTime nextPeriodStartDate,
    required DateTime nextFertileWindowStartDate,
    required String cycleDayInsight,
  }) = DataHomeState;
}
