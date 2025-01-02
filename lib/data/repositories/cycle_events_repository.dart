import 'package:awesome_period_tracker/app/core/extensions/date_time_extensions.dart';
import 'package:awesome_period_tracker/domain/models/cycle_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

@injectable
class CycleEventsRepository {
  const CycleEventsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const _cycleEventsPath = 'cycle_events';

  CollectionReference get _collection =>
      _firestore.collection(_cycleEventsPath);

  Future<List<CycleEvent>> get([Map<String, dynamic>? query]) async {
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
        .then((s) => s.docs.map(CycleEvent.fromFirestore).toList());
  }

  Future<CycleEvent?> getByDate(DateTime date) async {
    final snapshot = await _collection
        .where(
          'date',
          isEqualTo: Timestamp.fromDate(date.withoutTime()),
        )
        .get();

    if (snapshot.docs.isEmpty) return null;

    return CycleEvent.fromFirestore(snapshot.docs.first);
  }

  /// Create a new [CycleEvent] in Firestore.
  ///
  /// The [CycleEvent.date] will have its time removed before being added to Firestore.
  Future<void> create(CycleEvent cycleEvent) async {
    final updatedCycleEvent =
        cycleEvent.copyWith(date: cycleEvent.date.withoutTime());

    await _collection.add(updatedCycleEvent.toFirestore());
  }

  Future<void> update(CycleEvent cycleEvent) async {
    final updatedCycleEvent =
        cycleEvent.copyWith(date: cycleEvent.date.withoutTime());

    await _collection
        .doc(cycleEvent.id)
        .update(updatedCycleEvent.toFirestore());
  }

  Future<void> delete(CycleEvent cycleEvent) async {
    await _collection.doc(cycleEvent.id).delete();
  }
}
