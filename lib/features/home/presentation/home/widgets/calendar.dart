import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatelessWidget {
  const Calendar({
    required this.cycleEvents,
    required this.onDaySelected,
    super.key,
  });

  final List<CycleEvent> cycleEvents;
  final Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
      child: TableCalendar<CycleEvent>(
        firstDay: DateTime(DateTime.now().year - 10),
        lastDay: DateTime(DateTime.now().year + 10),
        focusedDay: DateTime.now(),
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
      todayTextStyle: context.primaryTextTheme.bodyMedium!.copyWith(
        color: context.colorScheme.surface,
      ),
      todayDecoration: BoxDecoration(
        color: context.colorScheme.secondary,
        shape: BoxShape.circle,
      ),
    );
  }

  CalendarBuilders<CycleEvent> _calendarBuilders(BuildContext context) {
    return CalendarBuilders(markerBuilder: _buildEventMarker);
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