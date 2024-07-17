import 'package:awesome_period_tracker/core/extensions/string_extensions.dart';

enum PeriodFlow {
  light,
  medium,
  heavy;

  String get title => name.camelToTitle();

  factory PeriodFlow.fromTitle(String title) {
    return PeriodFlow.values.firstWhere((flow) => flow.title == title);
  }
}
