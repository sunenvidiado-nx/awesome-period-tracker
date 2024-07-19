import 'package:awesome_period_tracker/core/extensions/date_time_extensions.dart';
import 'package:awesome_period_tracker/core/providers/firebase_firestore_provider.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CycleEventsRepository {
  const CycleEventsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const _collectionPath = 'cycle_events';

  CollectionReference get _collection => _firestore.collection(_collectionPath);

  /// Returns a list of [CycleEvent]s from Firestore.
  ///
  /// If [dateTime] is provided, only [CycleEvent]s that match the date will be returned.
  Future<List<CycleEvent>> getCycleEvents([DateTime? dateTime]) async {
    final query = dateTime == null
        ? _collection.get()
        : _collection
            .where(
              'date',
              isEqualTo: Timestamp.fromDate(dateTime.withoutTime()),
            )
            .get();

    return query.then(
      (snapshot) => snapshot.docs.map(CycleEvent.fromFirestore).toList(),
    );
  }

  /// Adds a [CycleEvent] to Firestore.
  ///
  /// The [CycleEvent.date] will have its time removed before being added to Firestore.
  Future<void> addCycleEvent(CycleEvent cycleEvent) async {
    final updatedCycleEvent =
        cycleEvent.copyWith(date: cycleEvent.date.withoutTime());

    await _collection.add(updatedCycleEvent.toFirestore());
  }
}

final cycleEventsRepositoryProvider = Provider.autoDispose((ref) {
  return CycleEventsRepository(ref.watch(firebaseFirestoreProvider));
});
