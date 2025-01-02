import 'package:awesome_period_tracker/core/extensions/date_time_extensions.dart';
import 'package:awesome_period_tracker/core/infrastructure/state_manager.dart';
import 'package:awesome_period_tracker/features/home/data/ai_insights_service.dart';
import 'package:awesome_period_tracker/features/home/data/cycle_events_repository.dart';
import 'package:awesome_period_tracker/features/home/data/forecast_service.dart';
import 'package:awesome_period_tracker/features/home/domain/forecast.dart';
import 'package:awesome_period_tracker/features/home/domain/insight.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:injectable/injectable.dart';

part 'home_state.dart';
part 'home_state_manager.mapper.dart';

@injectable
class HomeStateManager extends StateManager<HomeState> {
  HomeStateManager(
    this._cycleEventsRepository,
    this._forecastService,
    this._insightsService,
  ) : super(HomeState.initial());

  final CycleEventsRepository _cycleEventsRepository;
  final ForecastService _forecastService;
  final AiInsightsService _insightsService;

  Future<void> initialize({DateTime? date, bool useCache = true}) async {
    try {
      date ??= DateTime.now().withoutTime();

      notifier.value =
          notifier.value.copyWith(isLoading: true, selectedDate: date);

      final forecast = await _forecastService.createForecastForDateFromEvents(
        date: date,
        events: await _cycleEventsRepository.get(),
      );

      final insight = await _insightsService.getInsightForForecast(
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
