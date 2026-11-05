import '../../core/errors/app_exception.dart';
import '../../core/utils/formatters.dart';
import '../entities/agent_client.dart';
import '../entities/app_user.dart';
import '../entities/booking.dart';
import '../entities/dispute.dart';
import '../entities/equipment.dart';
import '../entities/expert.dart';
import '../repositories/admin_repository.dart';
import '../repositories/booking_repository.dart';
import '../repositories/notification_repository.dart';
import '../validators.dart';
import 'pricing.dart';

/// Booking, payment and dispute rules. Every state change also tells the
/// other party through a notification.
class BookingUseCases {
  BookingUseCases(this._bookings, this._notifications, this._admin);

  final BookingRepository _bookings;
  final NotificationRepository _notifications;
  final AdminRepository _admin;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /// `Sat, 14 Nov 2026 · 08:00` — the long label stored on a booking.
  static String scheduledLabel(DateTime date, String time) =>
      '${_weekdays[date.weekday - 1]}, ${dayMonth(date)} ${date.year} · $time';

  /// A farmer (or an agent for a client) hires a machine.
  Future<String> bookEquipment({
    required Equipment equipment,
    required DateTime date,
    required String startTime,
    required String durationOption,
    required String location,
    AppUser? farmer,
    AppUser? agent,
    AgentClient? client,
  }) async {
    if (equipment.status == EquipmentStatus.maintenance) {
      throw const AppException('This machine is under maintenance right now.');
    }
    final error = Validators.required(location, 'Farm location');
    if (error != null) throw AppException(error);
    if (farmer == null && (agent == null || client == null)) {
      throw const AppException('Please log in to book.');
    }

    final quote = BookingPricing.quote(
      price: equipment.price,
      quantity: BookingPricing.quantityOf(durationOption),
    );
    final byAgent = agent != null && client != null;
    final ref = await _bookings.create(NewBooking(
      kind: BookingKind.equipment,
      title: equipment.name,
      image: equipment.image,
      itemId: equipment.id,
      dateLabel: dayMonth(date),
      scheduled: scheduledLabel(date, startTime),
      detail: durationOption,
      place: equipment.district,
      location: location.trim(),
      total: quote.total,
      farmerId: byAgent ? '' : farmer!.uid,
      farmerName: byAgent ? '' : farmer!.name,
      providerId: equipment.ownerId,
      providerName: equipment.ownerName,
      agentId: byAgent ? agent.uid : '',
      clientName: byAgent ? client.name : '',
    ));
    if (equipment.ownerId.isNotEmpty) {
      final who = byAgent ? client.name : farmer!.name;
      await _notifications.add(equipment.ownerId, 'New booking request',
          '$who requested ${equipment.name} for ${dayMonth(date)}.', 'booking');
    }
    return ref;
  }

  /// A farmer books a consultation with an expert.
  Future<String> bookExpert({
    required Expert expert,
    required AppUser farmer,
    required DateTime date,
    required String time,
    required String mode,
    required String topic,
  }) async {
    if (!expert.accepting) {
      throw const AppException('This expert is not taking new consultations.');
    }
    final error = Validators.required(topic, 'Topic');
    if (error != null) throw AppException(error);
    final ref = await _bookings.create(NewBooking(
      kind: BookingKind.consult,
      title: topic.trim(),
      image: '',
      itemId: expert.id,
      dateLabel: dayMonth(date),
      scheduled: scheduledLabel(date, time),
      detail: mode,
      place: expert.field,
      location: mode,
      total: expert.fee,
      farmerId: farmer.uid,
      farmerName: farmer.name,
      providerId: expert.id,
      providerName: expert.name,
    ));
    await _notifications.add(expert.id, 'New consultation request',
        '${farmer.name} asked about "${topic.trim()}" for ${dayMonth(date)}.', 'expert');
    return ref;
  }

  /// Records a Mobile Money payment (simulated until a payments backend exists).
  Future<void> pay(Booking booking, String via) async {
    await _bookings.markPaid(booking.ref, via);
    if (booking.farmerId.isNotEmpty) {
      await _notifications.add(booking.farmerId, 'Payment received',
          '${rwf(booking.total)} received via $via. Ref ${booking.ref}.', 'payment');
    }
    if (booking.providerId.isNotEmpty) {
      await _notifications.add(booking.providerId, 'Booking paid',
          '${booking.ref} was paid via $via.', 'payment');
    }
  }

  /// Accept, decline, complete or cancel a booking and notify the customer.
  Future<void> updateStatus(Booking booking, String status) async {
    await _bookings.setStatus(booking, status);
    final text = switch (status) {
      BookingStatus.confirmed =>
        '${booking.providerName} confirmed your booking for ${booking.dateLabel}.',
      BookingStatus.cancelled =>
        '${booking.providerName} could not take your booking for ${booking.dateLabel}.',
      BookingStatus.completed => 'Your booking ${booking.ref} is complete.',
      _ => 'Booking ${booking.ref} is now $status.',
    };
    for (final uid in {booking.farmerId, booking.agentId}) {
      if (uid.isNotEmpty) {
        await _notifications.add(uid, 'Booking ${status.toLowerCase()}', text,
            booking.expert ? 'expert' : 'booking');
      }
    }
  }

  Future<void> deleteBooking(Booking booking) async {
    if (!booking.earlier) {
      throw const AppException('Only completed or cancelled bookings can be deleted.');
    }
    await _bookings.delete(booking.ref);
  }

  Future<void> reportProblem(Booking booking, AppUser user, String reason) async {
    final error = Validators.reason(reason);
    if (error != null) throw AppException(error);
    await _admin.createDispute(Dispute(
      id: '',
      bookingRef: booking.ref,
      raisedBy: user.uid,
      raisedByName: user.name,
      reason: reason.trim(),
    ));
  }
}
