import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/extensions/color_extensions.dart';
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
        headerStyle: _headerStyle(context),
        onDaySelected: onDaySelected,
        calendarBuilders: CalendarBuilders(
          markerBuilder: _markerBuilder,
          todayBuilder: _todayBuilder,
          defaultBuilder: _defaultBuilder,
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
        top: 25,
        child: Icon(
          Icons.favorite,
          color: context.colorScheme.error
              .withOpacity(isBeforeOrAfterCurrentMonth ? 0.5 : 1),
          size: 11,
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
          color:
              event?.type.color ?? context.colorScheme.shadow.withOpacity(0.35),
          width: 1.2,
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: event?.type.color.withOpacity(event.isPrediction ? 0.5 : 1) ??
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

  Widget? _defaultBuilder(
    BuildContext context,
    DateTime date,
    DateTime focusedDay,
  ) {
    final events = _getEventsForDay(date).toList();

    if (events.isEmpty) return null;

    final event = events.firstWhere(
      (event) =>
          event.type == CycleEventType.period ||
          event.type == CycleEventType.fertile,
    );

    return Container(
      margin: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: event.type.color.withOpacity(event.isPrediction ? 0.5 : 1),
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
