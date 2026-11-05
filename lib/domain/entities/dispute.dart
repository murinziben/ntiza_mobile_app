/// A problem reported on a booking — `disputes/{id}`.
class Dispute {
  const Dispute({
    required this.id,
    required this.bookingRef,
    required this.raisedBy,
    required this.raisedByName,
    required this.reason,
    this.status = open,
    this.resolution = '',
    this.createdAt,
  });

  static const open = 'Open';
  static const resolved = 'Resolved';

  final String id;
  final String bookingRef;
  final String raisedBy;
  final String raisedByName;
  final String reason;
  final String status;
  final String resolution;
  final DateTime? createdAt;

  bool get isOpen => status == open;
}
