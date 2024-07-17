import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatelessWidget {
  const Calendar({
    required this.cycleEvents,
    required this.selectedDate,
    required this.onDaySelected,
    this.calendarFormat = CalendarFormat.month,
    super.key,
  });

  final List<CycleEvent> cycleEvents;
  final Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final DateTime selectedDate;
  final CalendarFormat calendarFormat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
      child: TableCalendar<CycleEvent>(
        firstDay: DateTime(DateTime.now().year - 10),
        lastDay: DateTime(DateTime.now().year + 10),
        focusedDay: selectedDate,
        calendarFormat: calendarFormat,
        eventLoader: _getEventsForDay,
        calendarBuilders: _calendarBuilders(context),
        headerStyle: _headerStyle(context),
        calendarStyle: _calendarStyle(context),
        onDaySelected: onDaySelected,
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

  CalendarStyle _calendarStyle(BuildContext context) {
    return CalendarStyle(
      defaultTextStyle: context.primaryTextTheme.bodyMedium!,
      selectedTextStyle: context.primaryTextTheme.bodyMedium!,
      selectedDecoration: BoxDecoration(
        color: context.colorScheme.primary,
        shape: BoxShape.circle,
      ),
      todayTextStyle: context.primaryTextTheme.bodyMedium!,
    );
  }

  CalendarBuilders<CycleEvent> _calendarBuilders(BuildContext context) {
    return CalendarBuilders(
      markerBuilder: _buildEventMarker,
      todayBuilder: _buildToday,
      defaultBuilder: _buildDefaultDay,
    );
  }

  Widget _buildToday(
    BuildContext context,
    DateTime day,
    DateTime focusedDay,
  ) {
    final isSelected = isSameDay(day, selectedDate);

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colorScheme.secondary.withOpacity(isSelected ? 0.16 : 0),
        border: Border.all(
          color:
              context.colorScheme.secondary.withOpacity(isSelected ? 0 : 0.5),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          day.day.toString(),
          style: context.primaryTextTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildDefaultDay(
    BuildContext context,
    DateTime day,
    DateTime focusedDay,
  ) {
    final isSelected = isSameDay(day, selectedDate);

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            context.colorScheme.secondary.withOpacity(isSelected ? 0.16 : 0.0),
      ),
      child: Center(
        child: Text(
          day.day.toString(),
          style: context.primaryTextTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildEventMarker(
    BuildContext context,
    DateTime day,
    List<CycleEvent> events,
  ) {
    for (final eventType in CycleEventType.values) {
      final event = events.firstWhereOrNull((e) => e.type == eventType);
      if (event != null) {
        if (event.isPrediction) {
          return Opacity(opacity: 0.4, child: event.type.icon);
        }

        return event.type.icon;
      }
    }

    return const SizedBox.shrink();
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
