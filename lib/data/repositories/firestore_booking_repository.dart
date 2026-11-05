import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../mappers/firestore_mappers.dart';
import 'firebase_errors.dart';

/// Bookings stored in Cloud Firestore.
///
/// Each query filters on one participant and sorts by `createdAt`, which needs
/// the composite indexes declared in `firestore.indexes.json`.
class FirestoreBookingRepository implements BookingRepository {
  FirestoreBookingRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _bookings => _db.collection('bookings');

  Stream<List<Booking>> _watch(Query<Map<String, dynamic>> q) => q.snapshots().map(
        (s) => [for (final d in s.docs) bookingFromMap(d.id, d.data())],
      );

  @override
  Stream<List<Booking>> watchForFarmer(String uid) => _watch(
      _bookings.where('farmerId', isEqualTo: uid).orderBy('createdAt', descending: true));

  @override
  Stream<List<Booking>> watchForProvider(String uid) => _watch(
      _bookings.where('providerId', isEqualTo: uid).orderBy('createdAt', descending: true));

  @override
  Stream<List<Booking>> watchForAgent(String uid) => _watch(
      _bookings.where('agentId', isEqualTo: uid).orderBy('createdAt', descending: true));

  @override
  Stream<List<Booking>> watchAll() => _watch(_bookings.orderBy('createdAt', descending: true));

  @override
  Future<String> create(NewBooking booking) => guardData(() {
        final counter = _db.collection('meta').doc('counters');
        return _db.runTransaction<String>((tx) async {
          final snap = await tx.get(counter);
          final current = snap.data()?['booking'];
          final n = (current is num ? current.toInt() : 2040) + 1;
          tx.set(counter, {'booking': n}, SetOptions(merge: true));
          final ref = 'NTZ-$n';
          tx.set(_bookings.doc(ref), newBookingToMap(booking));
          return ref;
        });
      });

  @override
  Future<void> markPaid(String ref, String via) =>
      guardData(() => _bookings.doc(ref).update({'paidVia': via}));

  @override
  Future<void> setStatus(Booking booking, String status) => guardData(() async {
        await _bookings.doc(booking.ref).update({'status': status});
        if (status == BookingStatus.completed &&
            booking.kind == BookingKind.equipment &&
            booking.itemId.isNotEmpty) {
          await _db
              .collection('equipment')
              .doc(booking.itemId)
              .update({'jobs': FieldValue.increment(1)});
        }
      });

  @override
  Future<void> delete(String ref) => guardData(() => _bookings.doc(ref).delete());
}
