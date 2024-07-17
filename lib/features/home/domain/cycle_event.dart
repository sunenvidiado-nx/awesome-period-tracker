import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'cycle_event.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class CycleEvent with CycleEventMappable {
  final String? id;
  final DateTime date;
  final CycleEventType type;
  final String? additionalData;
  final bool isPrediction;
  final String createdBy;

  DateTime get localDate => date.toLocal();

  const CycleEvent({
    required this.date,
    required this.type,
    required this.createdBy,
    this.isPrediction = false,
    this.id,
    this.additionalData,
  });

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
    return toMap()..['date'] = Timestamp.fromDate(date.toUtc());
  }
}
