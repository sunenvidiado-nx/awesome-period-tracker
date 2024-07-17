import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

extension DateTimeExtensions on DateTime {
  String toReadableString() {
    return DateFormat('MMMM d, yyyy').format(this);
  }

  DateTime withoutTime() => DateTime(year, month, day);

  bool get isToday => isSameDay(DateTime.now(), this);
}
