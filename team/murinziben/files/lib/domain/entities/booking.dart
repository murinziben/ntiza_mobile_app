import '../../core/utils/formatters.dart';

/// Allowed values of `bookings.status`.
class BookingStatus {
  BookingStatus._();
  static const pending = 'Pending';
  static const confirmed = 'Confirmed';
  static const completed = 'Completed';
  static const cancelled = 'Cancelled';
}

/// `bookings.kind`.
class BookingKind {
  BookingKind._();
  static const equipment = 'equipment';
  static const consult = 'consult';
}

/// A hire request for a machine or a consultation — `bookings/{ref}`.
///
/// Title, image, place and the two names are a snapshot taken when the booking
/// is made, so history stays correct if the equipment is later edited.
class Booking {
  const Booking({
    required this.ref,
    required this.kind,
    required this.title,
    required this.image,
    required this.status,
    required this.dateLabel,
    required this.detail,
    required this.place,
    required this.total,
    required this.farmerId,
    required this.farmerName,
    required this.providerId,
    required this.providerName,
    this.itemId = '',
    this.scheduled = '',
    this.location = '',
    this.paidVia,
    this.agentId = '',
    this.clientName = '',
    this.createdAt,
  });

  final String ref;

  /// [BookingKind.equipment] or [BookingKind.consult].
  final String kind;
  final String title;
  final String image;
  final String status;
  final String dateLabel;
  final String detail;
  final String place;
  final int total;

  /// The farmer who pays. Empty when an agent booked for an offline client.
  final String farmerId;
  final String farmerName;

  /// The equipment owner or expert who delivers the service.
  final String providerId;
  final String providerName;

  /// Equipment or expert id this booking is for.
  final String itemId;
  final String scheduled;
  final String location;
  final String? paidVia;

  /// Set when an agent created the booking (commission is earned on it).
  final String agentId;
  final String clientName;
  final DateTime? createdAt;

  bool get expert => kind == BookingKind.consult;
  bool get isPaid => paidVia != null && paidVia!.isNotEmpty;
  bool get earlier =>
      status == BookingStatus.completed || status == BookingStatus.cancelled;

  /// The name shown to the provider: the farmer, or the agent's client.
  String get customerName => farmerName.isNotEmpty ? farmerName : clientName;

  String get created => createdAt == null ? '' : dayMonth(createdAt!);
}
