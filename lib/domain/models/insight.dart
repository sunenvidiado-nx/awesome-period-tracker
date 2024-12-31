import 'package:freezed_annotation/freezed_annotation.dart';

part 'insight.freezed.dart';
part 'insight.g.dart';

@freezed
class Insight with _$Insight {
  const factory Insight({
    required DateTime date,
    required String insights,
    required bool isPast,
  }) = _Insight;

  factory Insight.fromJson(Map<String, dynamic> json) =>
      _$InsightFromJson(json);
}
