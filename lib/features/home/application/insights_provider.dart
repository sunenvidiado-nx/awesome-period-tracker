import 'package:awesome_period_tracker/features/home/application/cycle_predictions_provider.dart';
import 'package:awesome_period_tracker/features/home/data/insights_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InsightsProviderParams {
  const InsightsProviderParams({
    required this.date,
    this.isPast = false,
    this.useCache = true,
  });

  final DateTime date;
  final bool isPast;
  final bool useCache;
}

final insightsProvider = FutureProvider.family
    .autoDispose((ref, InsightsProviderParams params) async {
  final predictions = await ref.watch(cyclePredictionsProvider.future);

  return ref.read(insightsRepositoryProvider).getInsightForDate(
        isPast: params.isPast,
        date: params.date,
        predictions: predictions,
        useCache: params.useCache,
      );
});
