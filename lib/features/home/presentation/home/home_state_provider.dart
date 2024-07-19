import 'package:awesome_period_tracker/features/home/data/cycle_events_repository.dart';
import 'package:awesome_period_tracker/features/home/data/period_predictions_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cycleEventsProvider = FutureProvider.autoDispose((ref) async {
  final loggedEvents =
      await ref.read(cycleEventsRepositoryProvider).getCycleEvents();

  return ref
      .read(periodPredictionsRepositoryProvider)
      .generatePeriodPredictions(loggedEvents);
});
