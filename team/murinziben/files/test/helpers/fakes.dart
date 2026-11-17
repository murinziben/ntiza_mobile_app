import 'dart:async';

import 'package:ntiza/domain/entities/entities.dart';
import 'package:ntiza/domain/repositories/admin_repository.dart';
import 'package:ntiza/domain/repositories/auth_repository.dart';
import 'package:ntiza/domain/repositories/booking_repository.dart';
import 'package:ntiza/domain/repositories/catalog_repository.dart';
import 'package:ntiza/domain/repositories/notification_repository.dart';
import 'package:ntiza/domain/repositories/settings_repository.dart';

/// In-memory test doubles for the domain repositories. They record what was
/// called so tests can assert on behaviour without Firebase.

class FakeAuthRepository implements AuthRepository {
  final sessions = StreamController<AuthSession?>.broadcast();
  final saved = <AppUser>[];
  final calls = <String>[];
  Object? failWith;

  @override
  Stream<AuthSession?> watchSession() => sessions.stream;

  @override
  Stream<AppUser?> watchProfile(String uid) => Stream.value(null);

  void _maybeFail() {
    if (failWith != null) throw failWith!;
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    _maybeFail();
    calls.add('signIn:$email');
  }

  @override
  Future<AuthSession> registerWithEmail(String email, String password) async {
    _maybeFail();
    calls.add('register:$email');
    return AuthSession(uid: 'u1', email: email, emailVerified: false, usesPassword: true);
  }

  @override
  Future<void> signInWithGoogle() async => calls.add('google');

  @override
  Future<void> sendPasswordReset(String email) async => calls.add('reset:$email');

  @override
  Future<void> sendEmailVerification() async => calls.add('verify');

  @override
  Future<void> reloadSession() async => calls.add('reload');

  @override
  Future<void> signOut() async => calls.add('signOut');

  @override
  Future<void> saveProfile(AppUser profile) async => saved.add(profile);

  @override
  Future<void> updateProfile(String uid, {String? name, String? phone, String? district}) async =>
      calls.add('update:$uid:$name:$phone:$district');
}

class FakeBookingRepository implements BookingRepository {
  final created = <NewBooking>[];
  final statusChanges = <String>[];
  final paid = <String>[];
  final deleted = <String>[];
  List<Booking> farmerBookings = const [];
  List<Booking> providerBookings = const [];

  @override
  Stream<List<Booking>> watchForFarmer(String uid) => Stream.value(farmerBookings);

  @override
  Stream<List<Booking>> watchForProvider(String uid) => Stream.value(providerBookings);

  @override
  Stream<List<Booking>> watchForAgent(String uid) => Stream.value(const []);

  @override
  Stream<List<Booking>> watchAll() => Stream.value(const []);

  @override
  Future<String> create(NewBooking booking) async {
    created.add(booking);
    return 'NTZ-${2040 + created.length}';
  }

  @override
  Future<void> markPaid(String ref, String via) async => paid.add('$ref:$via');

  @override
  Future<void> setStatus(Booking booking, String status) async =>
      statusChanges.add('${booking.ref}:$status');

  @override
  Future<void> delete(String ref) async => deleted.add(ref);
}

class FakeNotificationRepository implements NotificationRepository {
  final added = <(String, String, String, String)>[];

  @override
  Stream<List<AppNotification>> watch(String uid) => Stream.value(const []);

  @override
  Future<void> add(String userId, String title, String body, String kind) async =>
      added.add((userId, title, body, kind));

  @override
  Future<void> markRead(String id) async {}

  @override
  Future<void> markAllRead(String uid) async {}

  @override
  Future<void> delete(String id) async {}
}

class FakeAdminRepository implements AdminRepository {
  final disputes = <Dispute>[];
  final decisions = <String>[];

  @override
  Stream<List<AppUser>> watchUsers() => Stream.value(const []);

  @override
  Future<void> decideApplication(AppUser user, {required bool approve}) async =>
      decisions.add('${user.uid}:$approve');

  @override
  Future<void> setUserStatus(String uid, String status) async {}

  @override
  Future<void> deleteUser(String uid) async {}

  @override
  Stream<List<Dispute>> watchDisputes() => Stream.value(disputes);

  @override
  Stream<List<Dispute>> watchDisputesRaisedBy(String uid) => Stream.value(disputes);

  @override
  Future<void> createDispute(Dispute dispute) async => disputes.add(dispute);

  @override
  Future<void> resolveDispute(String id, String resolution) async {}

  @override
  Future<void> deleteDispute(String id) async {}

  @override
  Future<void> seedDemoData() async {}
}

class FakeCatalogRepository implements CatalogRepository {
  final added = <Equipment>[];
  final updated = <Equipment>[];
  final deleted = <String>[];
  final experts = <Expert>[];

  @override
  Stream<List<Equipment>> watchEquipment() => Stream.value(added);

  @override
  Future<String> addEquipment(Equipment equipment) async {
    added.add(equipment);
    return 'eq${added.length}';
  }

  @override
  Future<void> updateEquipment(Equipment equipment) async => updated.add(equipment);

  @override
  Future<void> deleteEquipment(String id) async => deleted.add(id);

  @override
  Stream<List<Expert>> watchExperts() => Stream.value(experts);

  @override
  Future<void> saveExpert(Expert expert) async => experts.add(expert);

  @override
  Stream<List<Course>> watchCourses() => Stream.value(const []);
}

class FakeAgentRepository implements AgentRepository {
  final added = <AgentClient>[];
  final updated = <AgentClient>[];
  final deleted = <String>[];

  @override
  Stream<List<AgentClient>> watchClients(String agentId) => Stream.value(added);

  @override
  Future<void> addClient(AgentClient client) async => added.add(client);

  @override
  Future<void> updateClient(AgentClient client) async => updated.add(client);

  @override
  Future<void> deleteClient(String id) async => deleted.add(id);
}

class FakeSettingsRepository implements SettingsRepository {
  AppSettings stored = const AppSettings();
  int saves = 0;

  @override
  AppSettings load() => stored;

  @override
  Future<void> save(AppSettings settings) async {
    stored = settings;
    saves++;
  }
}

/// Sample entities reused across tests.
const sampleOwner = AppUser(
  uid: 'owner1',
  name: 'Agasaro Farm',
  role: Role.owner,
  status: UserStatus.active,
  district: 'Huye',
);

const sampleFarmer = AppUser(
  uid: 'farmer1',
  name: 'Uwase Esperance',
  role: Role.farmer,
  status: UserStatus.active,
  phone: '0781234567',
  district: 'Huye',
);

const sampleTractor = Equipment(
  id: 'eq1',
  name: 'Tractor 50HP',
  type: 'Tractor',
  district: 'Huye',
  sector: 'Mbazi',
  price: 25000,
  unit: 'hour',
  ownerId: 'owner1',
  ownerName: 'Agasaro Farm',
);

Booking sampleBooking({
  String ref = 'NTZ-2041',
  String status = BookingStatus.pending,
  int total = 100000,
  String kind = BookingKind.equipment,
  DateTime? createdAt,
  String agentId = '',
}) =>
    Booking(
      ref: ref,
      kind: kind,
      title: 'Tractor 50HP',
      image: 'tractor.jpg',
      status: status,
      dateLabel: '14 Nov',
      detail: '4 hours',
      place: 'Huye',
      total: total,
      farmerId: 'farmer1',
      farmerName: 'Uwase Esperance',
      providerId: 'owner1',
      providerName: 'Agasaro Farm',
      itemId: 'eq1',
      agentId: agentId,
      createdAt: createdAt,
    );
