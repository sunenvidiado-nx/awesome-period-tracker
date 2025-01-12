import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toReadableString() {
    return DateFormat('MMMM d, yyyy').format(this);
  }

  DateTime withoutTime() => DateTime(year, month, day);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool get isToday => isSameDay(DateTime.now());

  bool get isAfterToday => isAfter(DateTime.now());

  String toYmdString() => DateFormat('yyyy-MM-dd').format(this);

  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;

  String toMonthAndDay() => DateFormat('MMM d').format(this);

  bool isSameDayOrBefore(DateTime other) => isSameDay(other) || isBefore(other);
}
