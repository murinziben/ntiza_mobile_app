import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/agent_client.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/entities/expert.dart';
import '../providers/data_providers.dart';
import '../providers/dependencies.dart';
import 'action_notifier.dart';

/// Booking, payment, status changes and problem reports.
class BookingController extends ActionNotifier {
  Future<ActionResult<String>> bookEquipment({
    required Equipment equipment,
    required DateTime date,
    required String startTime,
    required String durationOption,
    required String location,
  }) =>
      run(() async {
        final farmer = ref.read(profileProvider).valueOrNull;
        if (farmer == null) throw const AppException('Please log in to book.');
        return ref.read(bookingUseCasesProvider).bookEquipment(
              equipment: equipment,
              date: date,
              startTime: startTime,
              durationOption: durationOption,
              location: location,
              farmer: farmer,
            );
      });

  /// An agent books a machine for one of their clients.
  Future<ActionResult<String>> bookForClient({
    required Equipment equipment,
    required AgentClient client,
    required DateTime date,
    required String startTime,
    required String durationOption,
    required String location,
  }) =>
      run(() async {
        final agent = ref.read(profileProvider).valueOrNull;
        if (agent == null) throw const AppException('Please log in again.');
        return ref.read(bookingUseCasesProvider).bookEquipment(
              equipment: equipment,
              date: date,
              startTime: startTime,
              durationOption: durationOption,
              location: location,
              agent: agent,
              client: client,
            );
      });

  Future<ActionResult<String>> bookExpert({
    required Expert expert,
    required DateTime date,
    required String time,
    required String mode,
    required String topic,
  }) =>
      run(() async {
        final farmer = ref.read(profileProvider).valueOrNull;
        if (farmer == null) throw const AppException('Please log in to book.');
        return ref.read(bookingUseCasesProvider).bookExpert(
              expert: expert,
              farmer: farmer,
              date: date,
              time: time,
              mode: mode,
              topic: topic,
            );
      });

  Future<ActionResult<void>> pay(Booking booking, String via) =>
      run(() => ref.read(bookingUseCasesProvider).pay(booking, via));

  Future<ActionResult<void>> updateStatus(Booking booking, String status) =>
      run(() => ref.read(bookingUseCasesProvider).updateStatus(booking, status));

  Future<ActionResult<void>> delete(Booking booking) =>
      run(() => ref.read(bookingUseCasesProvider).deleteBooking(booking));

  Future<ActionResult<void>> reportProblem(Booking booking, String reason) => run(() async {
        final user = ref.read(profileProvider).valueOrNull;
        if (user == null) throw const AppException('Please log in again.');
        await ref.read(bookingUseCasesProvider).reportProblem(booking, user, reason);
      });
}

final bookingControllerProvider =
    NotifierProvider<BookingController, ActionState>(BookingController.new);
