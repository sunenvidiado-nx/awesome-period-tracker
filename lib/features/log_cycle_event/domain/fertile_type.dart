import 'package:awesome_period_tracker/core/extensions/string_extensions.dart';

enum Fertility {
  low,
  high,
  peak;

  factory Fertility.fromTitle(String title) {
    return Fertility.values.firstWhere((type) => type.title == title);
  }

  String get title => name.camelToTitle();
}
