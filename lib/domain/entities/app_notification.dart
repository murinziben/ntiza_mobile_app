import '../../core/utils/formatters.dart';

/// An in-app notification — `notifications/{id}`.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.kind,
    this.unread = true,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String title;
  final String body;

  /// booking | payment | training | expert | dispute
  final String kind;
  final bool unread;
  final DateTime? createdAt;

  String get time => createdAt == null ? 'now' : timeAgo(createdAt!);
}
