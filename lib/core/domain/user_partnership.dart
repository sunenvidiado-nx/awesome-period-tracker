import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'user_partnership.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class UserPartnership with UserPartnershipMappable {
  const UserPartnership({
    required this.id,
    required this.partnershipId,
    required this.userId,
    required this.createdAt,
  });

  factory UserPartnership.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserPartnership(
      id: snapshot.id,
      partnershipId: data['partnership_id'] as String,
      userId: data['user_id'] as String,
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  final String id;
  final String partnershipId;
  final String userId;
  final DateTime createdAt;

  Map<String, dynamic> toFirestore() {
    return (toMap()..remove('id'))
      ..['created_at'] = Timestamp.fromDate(createdAt.toUtc());
  }
}
