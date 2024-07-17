import 'package:awesome_period_tracker/features/home/data/cycle_events_repository.dart';
import 'package:awesome_period_tracker/features/home/data/period_predictions_repository.dart';
import 'package:awesome_period_tracker/features/home/presentation/home_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeStateNotifier extends AsyncNotifier<HomeState> {
  late final _now = DateTime.now();

  @override
  Future<HomeState> build() async {
    try {
      final cycleEvents =
          await ref.read(cycleEventsRepositoryProvider).getCycleEvents();

      final periodPredictions = ref
          .read(periodPredictionsRepositoryProvider)
          .generatePeriodPredictions(cycleEvents);

      return HomeState(
        cycleEvents: [...cycleEvents, ...periodPredictions],
        selectedDate: _now,
      );
    } catch (e) {
      return HomeState(
        cycleEvents: [],
        selectedDate: _now,
        error: e as Exception,
      );
    }
  }

  void onDateSelected(DateTime selectedDate) {
    state = AsyncData(state.asData!.value.copyWith(selectedDate: selectedDate));
  }
}

final homeStateProvider = AsyncNotifierProvider<HomeStateNotifier, HomeState>(
  HomeStateNotifier.new,
);
