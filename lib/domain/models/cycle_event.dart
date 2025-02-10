import 'package:awesome_period_tracker/config/constants/strings.dart';
import 'package:awesome_period_tracker/domain/models/cycle_event_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'cycle_event.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class CycleEvent with CycleEventMappable {
  const CycleEvent({
    required this.date,
    required this.type,
    required this.createdBy,
    this.isPrediction = false,
    this.isUncertainPrediction = false,
    this.id,
    this.additionalData,
  });

  final String? id;
  final DateTime date;
  final CycleEventType type;
  final String? additionalData;
  final bool isPrediction;
  final bool isUncertainPrediction;
  final String createdBy;

  DateTime get localDate => date.toLocal();

  List<String> get symptoms {
    if (type != CycleEventType.symptoms) return [];

    return additionalData!
        .split(Strings.symptomSeparator)
        .map((e) => e.trim())
        .toList();
  }

  bool get isPeriod => type == CycleEventType.period;

  factory CycleEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CycleEventMapper.fromMap({
      ...data,
      'id': doc.id,
      'date': (data['date'] as Timestamp).toDate(),
    });
  }

  // Method to convert CycleEvent to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return (toMap()..remove('id'))..['date'] = Timestamp.fromDate(date.toUtc());
  }
}
