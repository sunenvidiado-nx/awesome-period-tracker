import 'package:awesome_period_tracker/core/providers/firebase_firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SymptomsRepository {
  const SymptomsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const _collectionPath = 'symptoms';
  static const _valueField = 'value';

  Future<void> create(String symptom) async {
    await _firestore.collection(_collectionPath).add({_valueField: symptom});
  }

  Future<List<String>> get() async {
    return _firestore
        .collection(_collectionPath)
        .get()
        .then((s) => s.docs.map((d) => d[_valueField] as String).toList());
  }

  Future<void> delete(String symptom) async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .where(_valueField, isEqualTo: symptom)
        .get()
        .then((s) => s.docs.first);

    await snapshot.reference.delete();
  }
}

final symptomsRepositoryProvider = Provider.autoDispose((ref) {
  return SymptomsRepository(ref.watch(firebaseFirestoreProvider));
});
