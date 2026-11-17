import '../entities/booking.dart';

/// Everything needed to create a booking; the reference is assigned by the repository.
class NewBooking {
  const NewBooking({
    required this.kind,
    required this.title,
    required this.image,
    required this.itemId,
    required this.dateLabel,
    required this.scheduled,
    required this.detail,
    required this.place,
    required this.location,
    required this.total,
    required this.farmerId,
    required this.farmerName,
    required this.providerId,
    required this.providerName,
    this.agentId = '',
    this.clientName = '',
  });

  final String kind;
  final String title;
  final String image;
  final String itemId;
  final String dateLabel;
  final String scheduled;
  final String detail;
  final String place;
  final String location;
  final int total;
  final String farmerId;
  final String farmerName;
  final String providerId;
  final String providerName;
  final String agentId;
  final String clientName;
}

abstract class BookingRepository {
  Stream<List<Booking>> watchForFarmer(String uid);
  Stream<List<Booking>> watchForProvider(String uid);
  Stream<List<Booking>> watchForAgent(String uid);
  Stream<List<Booking>> watchAll();

  /// Creates the booking as `Pending` and returns its reference (`NTZ-2041`).
  Future<String> create(NewBooking booking);

  Future<void> markPaid(String ref, String via);

  /// Updates the status. Completing a job also increments the equipment's counter.
  Future<void> setStatus(Booking booking, String status);

  Future<void> delete(String ref);
}
