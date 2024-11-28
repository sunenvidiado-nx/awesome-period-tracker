import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'partnership.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Partnership with PartnershipMappable {
  const Partnership({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.createdBy,
  });

  factory Partnership.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Partnership(
      id: snapshot.id,
      name: data['name'] as String,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      createdBy: data['created_by'] as String,
    );
  }

  final String id;
  final String name;
  final DateTime createdAt;
  final String createdBy;

  Map<String, dynamic> toFirestore() {
    return (toMap()..remove('id'))
      ..['created_at'] = Timestamp.fromDate(createdAt.toUtc());
  }
}
