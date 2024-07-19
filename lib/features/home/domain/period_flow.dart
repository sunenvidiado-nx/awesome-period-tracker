import 'package:awesome_period_tracker/core/extensions/string_extensions.dart';

enum PeriodFlow {
  light,
  medium,
  heavy;

  String get title => name.camelToTitle();

  factory PeriodFlow.fromString(String string) => PeriodFlow.values
      .firstWhere((flow) => flow.title == string.toLowerCase());
}
