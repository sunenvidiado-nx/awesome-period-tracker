import 'package:awesome_period_tracker/config/constants/strings.dart';
import 'package:awesome_period_tracker/domain/models/cycle_event_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cycle_event.freezed.dart';

@freezed
class CycleEvent with _$CycleEvent {
  const CycleEvent._();

  const factory CycleEvent({
    required DateTime date,
    required CycleEventType type,
    required String createdBy,
    String? additionalData,
    String? id,
    @Default(false) bool isPrediction,
  }) = _CycleEvent;

  factory CycleEvent.fromFirestore(DocumentSnapshot doc) {
    return CycleEvent(
      date: doc['date'].toDate(),
      type: CycleEventType.values.firstWhere(
        (t) => t.name == doc['type'],
      ),
      additionalData: doc['additional_data'],
      id: doc.id,
      isPrediction: doc['is_prediction'],
      createdBy: doc['created_by'],
    );
  }

  DateTime get localDate => date.toLocal();

  List<String> get symptoms {
    if (type != CycleEventType.symptoms) return [];

    return additionalData!
        .split(Strings.symptomSeparator)
        .map((e) => e.trim())
        .toList();
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date.toUtc()),
      'type': type.name,
      'additional_data': additionalData,
      'is_prediction': isPrediction,
      'createdBy': createdBy,
    };
  }
}
