import '../entities/app_notification.dart';

abstract class NotificationRepository {
  Stream<List<AppNotification>> watch(String uid);
  Future<void> add(String userId, String title, String body, String kind);
  Future<void> markRead(String id);
  Future<void> markAllRead(String uid);
  Future<void> delete(String id);
}
