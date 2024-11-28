import 'package:awesome_period_tracker/core/domain/user_partnership.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

@injectable
class UserPartnershipsRepository {
  const UserPartnershipsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const _collectionPath = 'user_partnerships';

  CollectionReference get _collection => _firestore.collection(_collectionPath);

  Future<List<UserPartnership>> get([Map<String, dynamic>? query]) async {
    late Query<Object?> firestoreQuery;

    if (query != null) {
      for (final entry in query.entries) {
        firestoreQuery = _collection.where(entry.key, isEqualTo: entry.value);
      }
    } else {
      firestoreQuery = _collection;
    }

    return firestoreQuery
        .get()
        .then((s) => s.docs.map(UserPartnership.fromFirestore).toList());
  }

  Future<UserPartnership> create(UserPartnership partnership) async {
    final result = await _collection.add(partnership.toFirestore());
    return partnership.copyWith(id: result.id);
  }

  Future<void> delete(UserPartnership partnership) async {
    await _collection.doc(partnership.id).delete();
  }
}
