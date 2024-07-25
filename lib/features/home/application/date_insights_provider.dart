import 'package:awesome_period_tracker/features/home/application/cycle_predictions_provider.dart';
import 'package:awesome_period_tracker/features/home/data/insights_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dateInsightsProvider =
    FutureProvider.family.autoDispose((ref, DateTime selectedDate) async {
  final predictions = await ref.watch(cyclePredictionsProvider.future);

  return ref
      .read(insightsRepositoryProvider)
      .getInsightForDate(selectedDate, predictions);
});
