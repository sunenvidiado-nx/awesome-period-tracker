import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class TimestampConverter implements JsonConverter<DateTime, Object> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is Timestamp) {
      return json.toDate();
    } else {
      throw Exception('Can only convert Timestamp to DateTime');
    }
  }

  @override
  Object toJson(DateTime object) {
    return Timestamp.fromDate(object);
  }
}
