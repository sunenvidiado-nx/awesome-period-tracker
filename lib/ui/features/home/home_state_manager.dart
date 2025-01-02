import 'package:awesome_period_tracker/app/state/state_manager.dart';
import 'package:awesome_period_tracker/data/repositories/cycle_events_repository.dart';
import 'package:awesome_period_tracker/data/services/ai_insights_service.dart';
import 'package:awesome_period_tracker/data/services/forecast_service.dart';
import 'package:awesome_period_tracker/domain/models/forecast.dart';
import 'package:awesome_period_tracker/domain/models/insight.dart';
import 'package:awesome_period_tracker/utils/extensions/date_time_extensions.dart';
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
      state = state.copyWith(isLoading: true, selectedDate: date);

      date ??= DateTime.now().withoutTime();

      final forecast = await _forecastService.createForecastForDateFromEvents(
        date: date,
        events: await _cycleEventsRepository.get(),
      );

      final insight = await _insightsService.getInsightForForecast(
        forecast: forecast,
        useCache: useCache,
      );

      state = state.copyWith(forecast: forecast, insight: insight);
    } on Exception catch (error) {
      state = state.copyWith(error: error);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Updates the selected date in the [HomeState] with the time part removed.
  void changeSelectedDateAndReinitialize({
    required DateTime date,
    bool useCache = true,
  }) {
    state = state.copyWith(selectedDate: date.withoutTime());
    initialize(date: date.withoutTime(), useCache: useCache);
  }
}
