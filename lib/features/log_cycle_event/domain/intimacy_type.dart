import 'package:awesome_period_tracker/core/extensions/string_extensions.dart';

enum IntimacyType {
  usedProtection,
  noProtection;

  factory IntimacyType.fromTitle(String title) {
    return IntimacyType.values.firstWhere((type) => type.title == title);
  }

  String get title => name.camelToTitle();
}
