import 'package:awesome_period_tracker/core/extensions/string_extensions.dart';

enum Symptoms {
  pain,
  physical,
  emotional,
  other;

  String get title => name.camelToTitle();

  factory Symptoms.fromString(String string) =>
      Symptoms.values.firstWhere((symptom) => symptom.title == string);

  /// A separator used to join a list of symptoms into a single string.
  ///
  /// This separator is used to join a list of symptoms into a single string
  /// before saving it to the database. It is also used to split the string
  /// back into a list of symptoms when retrieving it from the database.
  static const separator = '|##|';
}
