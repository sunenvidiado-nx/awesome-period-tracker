import 'package:awesome_period_tracker/core/data/cycle_events_repository.dart';
import 'package:awesome_period_tracker/core/extensions/date_time_extensions.dart';
import 'package:awesome_period_tracker/core/infrastructure/state_manager.dart';
import 'package:awesome_period_tracker/features/home/data/forecast_repository.dart';
import 'package:awesome_period_tracker/features/home/data/insights_repository.dart';
import 'package:awesome_period_tracker/features/home/domain/forecast.dart';
import 'package:awesome_period_tracker/features/home/domain/insight.dart';
import 'package:injectable/injectable.dart';

part 'home_state.dart';

@injectable
class HomeStateManager extends StateManager<HomeState> {
  HomeStateManager(
    this._cycleEventsRepository,
    this._forecastRepository,
    this._insightsRepository,
  ) : super(HomeState.initial());

  final CycleEventsRepository _cycleEventsRepository;
  final ForecastRepository _forecastRepository;
  final InsightsRepository _insightsRepository;

  Future<void> initialize({DateTime? date, bool useCache = true}) async {
    try {
      date ??= DateTime.now().withoutTime();

      notifier.value =
          notifier.value.copyWith(isLoading: true, selectedDate: date);

      final forecast = _forecastRepository.createForecastForDateFromEvents(
        date: date,
        events: await _cycleEventsRepository.get(),
      );
      final insight = await _insightsRepository.getInsightForForecast(
        forecast: forecast,
        useCache: useCache,
      );

      notifier.value =
          notifier.value.copyWith(forecast: forecast, insight: insight);
    } catch (e) {
      // TODO Handle error
    } finally {
      notifier.value = notifier.value.copyWith(isLoading: false);
    }
  }

  /// Updates the selected date in the [HomeState] with the time part removed.
  void changeSelectedDateAndReinitialize({
    required DateTime date,
    bool useCache = true,
  }) {
    notifier.value = notifier.value.copyWith(selectedDate: date.withoutTime());
    initialize(date: date.withoutTime(), useCache: useCache);
  }
}
