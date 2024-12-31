import 'package:awesome_period_tracker/config/state_manager.dart';
import 'package:awesome_period_tracker/data/repositories/auth_repository.dart';
import 'package:awesome_period_tracker/data/repositories/cycle_events_repository.dart';
import 'package:awesome_period_tracker/domain/models/cycle_event.dart';
import 'package:awesome_period_tracker/domain/models/cycle_phase.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'home_state.dart';
part 'home_state_manager.freezed.dart';

@injectable
class HomeStateManager extends StateManager<HomeState> {
  HomeStateManager(
    this._authRepository,
    this._cycleEventsRepository,
  ) : super(const HomeState.loading());

  final AuthRepository _authRepository;
  final CycleEventsRepository _cycleEventsRepository;

  Future<void> initialize([DateTime? selectedDate]) async {
    try {
      final userName = _authRepository.user!.displayName!;

      selectedDate ??= DateTime.now();

      final events = await _cycleEventsRepository.get();

      await Future.delayed(const Duration(seconds: 3));

      state = HomeState.data(
        events: events,
        selectedDate: selectedDate,
        userName: userName,
        lowChanceOfPregnancy: true,
        cyclePhase: CyclePhase.menstruation,
        nextPeriodStartDate: selectedDate,
        nextFertileWindowStartDate: selectedDate,
        cycleDayInsight: 'Lorem ipsum dolor sit amet',
      );
    } catch (e) {
      state = HomeState.error(e.toString());
    }
  }

  Future<void> changeSelectedDate(DateTime selectedDate) async {
    try {
      await initialize(selectedDate);
    } catch (e) {
      state = HomeState.error(e.toString());
    }
  }
}
