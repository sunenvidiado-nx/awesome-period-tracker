import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

extension DateTimeExtensions on DateTime {
  String toReadableString() {
    return DateFormat('MMMM d, yyyy').format(this);
  }

  DateTime withoutTime() => DateTime(year, month, day);

  bool get isToday => isSameDay(DateTime.now(), this);

  String toYmdString() => DateFormat('yyyy-MM-dd').format(this);

  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;

  String toMonthAndDay() => DateFormat('MMM d').format(this);
}
