import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/extensions/color_extensions.dart';
import 'package:awesome_period_tracker/core/extensions/date_time_extensions.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatelessWidget {
  const Calendar({
    required this.cycleEvents,
    required this.onDaySelected,
    required this.selectedDate,
    super.key,
  });

  final List<CycleEvent> cycleEvents;
  final Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TableCalendar<CycleEvent>(
                key: ValueKey(cycleEvents),
                firstDay: DateTime(DateTime.now().year - 10),
                lastDay: DateTime(DateTime.now().year + 10),
                focusedDay: selectedDate,
                eventLoader: _getEventsForDay,
                headerStyle: _headerStyle(context),
                onDaySelected: onDaySelected,
                selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: _markerBuilder,
                  todayBuilder: _todayBuilder,
                  selectedBuilder: _selectedBuilder,
                  defaultBuilder: _defaultBuilder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  HeaderStyle _headerStyle(BuildContext context) {
    return HeaderStyle(
      formatButtonVisible: false,
      titleCentered: true,
      titleTextStyle: context.primaryTextTheme.titleMedium!,
      leftChevronIcon: const Icon(
        Icons.chevron_left_rounded,
        size: 32,
        color: Colors.black54,
      ),
      rightChevronIcon: const Icon(
        Icons.chevron_right_rounded,
        size: 32,
        color: Colors.black54,
      ),
    );
  }

  Widget _markerBuilder(
    BuildContext context,
    DateTime date,
    List<CycleEvent> events,
  ) {
    if (events.any((event) => event.type == CycleEventType.intimacy)) {
      final isBeforeOrAfterCurrentMonth = date.month < DateTime.now().month ||
          date.month > DateTime.now().month ||
          date.year != DateTime.now().year;

      return Positioned.fill(
        top: 24,
        child: Icon(
          Icons.favorite,
          color: context.colorScheme.error
              .withOpacity(isBeforeOrAfterCurrentMonth ? 0.5 : 1),
          size: 10,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _todayBuilder(
    BuildContext context,
    DateTime date,
    DateTime focusedDay,
  ) {
    final isTodayFocused = isSameDay(date, focusedDay);
    final events = _getEventsForDay(date).toList();
    final event = events.firstWhereOrNull(
      (event) =>
          event.type == CycleEventType.period ||
          event.type == CycleEventType.fertile,
    );

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isTodayFocused
              ? event?.type.color.darken(0.1) ??
                  context.colorScheme.shadow.withOpacity(0.35)
              : Colors.transparent,
          width: 2.3,
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: event?.type.color.withOpacity(event.isPrediction ? 0.2 : 1) ??
              Colors.transparent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          date.day.toString(),
          style: TextStyle(
            color: event != null
                ? event.isPrediction
                    ? event.type.color.darken(0.4)
                    : context.colorScheme.surface
                : null,
          ),
        ),
      ),
    );
  }

  Widget _selectedBuilder(
    BuildContext context,
    DateTime date,
    DateTime focusedDay,
  ) {
    final events = _getEventsForDay(date).toList();

    // If the selected day is today, return a "today" widget
    if ((isSameDay(selectedDate, focusedDay) && date.isToday) ||
        events.isNotEmpty) {
      return _todayBuilder(context, date, focusedDay);
    }

    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: context.colorScheme.shadow.withOpacity(0.5),
          width: 2.3,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(5),
        alignment: Alignment.center,
        child: Text(date.day.toString()),
      ),
    );
  }

  Widget? _defaultBuilder(
    BuildContext context,
    DateTime date,
    DateTime focusedDay,
  ) {
    if (!date.isSameMonth(focusedDay)) return null;

    final events = _getEventsForDay(date).toList();

    if (events.isEmpty) return null;

    final event = events.firstWhereOrNull(
      (event) =>
          event.type == CycleEventType.period ||
          event.type == CycleEventType.fertile,
    );

    if (event == null) return null;

    return Container(
      margin: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: event.type.color.withOpacity(event.isPrediction ? 0.2 : 1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        date.day.toString(),
        style: TextStyle(
          color: event.isPrediction
              ? event.type.color.darken(0.4)
              : context.colorScheme.surface,
        ),
      ),
    );
  }

  List<CycleEvent> _getEventsForDay(DateTime day) {
    return cycleEvents.where((event) {
      final eventDate = DateTime.utc(
        event.date.year,
        event.date.month,
        event.date.day,
      );
      return eventDate.isAtSameMomentAs(day);
    }).toList();
  }
}
