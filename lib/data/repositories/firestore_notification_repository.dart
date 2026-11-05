import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../mappers/firestore_mappers.dart';
import 'firebase_errors.dart';

/// Notifications stored in Cloud Firestore.
class FirestoreNotificationRepository implements NotificationRepository {
  FirestoreNotificationRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('notifications');

  @override
  Stream<List<AppNotification>> watch(String uid) => _col
      .where('userId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((q) => [for (final d in q.docs) notificationFromMap(d.id, d.data())]);

  @override
  Future<void> add(String userId, String title, String body, String kind) =>
      guardData(() => _col.add(notificationToMap(userId, title, body, kind)));

  @override
  Future<void> markRead(String id) =>
      guardData(() => _col.doc(id).update({'unread': false}));

  @override
  Future<void> markAllRead(String uid) => guardData(() async {
        final unread =
            await _col.where('userId', isEqualTo: uid).where('unread', isEqualTo: true).get();
        final batch = _db.batch();
        for (final d in unread.docs) {
          batch.update(d.reference, {'unread': false});
        }
        await batch.commit();
      });

  @override
  Future<void> delete(String id) => guardData(() => _col.doc(id).delete());
}
