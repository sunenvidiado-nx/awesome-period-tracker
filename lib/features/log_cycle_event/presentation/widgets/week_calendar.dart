import 'package:awesome_period_tracker/core/widgets/calendar/calendar.dart';
import 'package:awesome_period_tracker/core/widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/features/home/presentation/home_state_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

class WeekCalendar extends ConsumerWidget {
  const WeekCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeStateProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: AppCard(
        child: Calendar(
          calendarFormat: CalendarFormat.week,
          cycleEvents: state.maybeWhen(
            orElse: () => [],
            data: (state) => state.cycleEvents,
          ),
          selectedDate: state.maybeWhen(
            orElse: () => DateTime.now(),
            data: (state) => state.selectedDate,
          ),
          onDaySelected: (selectedDay, _) {
            ref.read(homeStateProvider.notifier).onDateSelected(selectedDay);
          },
        ),
      ),
    );
  }
}
