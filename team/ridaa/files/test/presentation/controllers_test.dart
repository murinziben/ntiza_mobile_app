import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntiza/core/errors/app_exception.dart';
import 'package:ntiza/domain/entities/entities.dart';
import 'package:ntiza/presentation/providers/dependencies.dart';
import 'package:ntiza/presentation/providers/providers.dart';

import '../helpers/fakes.dart';

/// Builds a container wired to in-memory fakes, signed in as [me].
({
  ProviderContainer container,
  FakeAuthRepository auth,
  FakeBookingRepository bookings,
  FakeNotificationRepository notifications,
  FakeCatalogRepository catalog,
  FakeAgentRepository agents,
  FakeSettingsRepository settings,
}) _setup({AppUser? me = sampleFarmer}) {
  final auth = FakeAuthRepository();
  final bookings = FakeBookingRepository();
  final notifications = FakeNotificationRepository();
  final catalog = FakeCatalogRepository();
  final agents = FakeAgentRepository();
  final settings = FakeSettingsRepository();
  final container = ProviderContainer(overrides: [
    authRepositoryProvider.overrideWithValue(auth),
    bookingRepositoryProvider.overrideWithValue(bookings),
    notificationRepositoryProvider.overrideWithValue(notifications),
    adminRepositoryProvider.overrideWithValue(FakeAdminRepository()),
    catalogRepositoryProvider.overrideWithValue(catalog),
    agentRepositoryProvider.overrideWithValue(agents),
    settingsRepositoryProvider.overrideWithValue(settings),
    currentUidProvider.overrideWithValue(me?.uid),
    profileProvider.overrideWith((ref) => Stream.value(me)),
  ]);
  addTearDown(container.dispose);
  return (
    container: container,
    auth: auth,
    bookings: bookings,
    notifications: notifications,
    catalog: catalog,
    agents: agents,
    settings: settings,
  );
}

void main() {
  group('ActionNotifier', () {
    test('turns an AppException into a message and clears busy', () async {
      final t = _setup();
      final controller = t.container.read(authControllerProvider.notifier);
      final result = await controller.run<void>(() async => throw const AppException('Nope'));
      expect(result.ok, isFalse);
      expect(result.error, 'Nope');
      expect(t.container.read(authControllerProvider).busy, isFalse);
    });

    test('hides unexpected errors behind a friendly message', () async {
      final t = _setup();
      final result = await t.container
          .read(authControllerProvider.notifier)
          .run<void>(() async => throw StateError('internal detail'));
      expect(result.error, isNot(contains('internal detail')));
    });

    test('returns the value on success', () async {
      final t = _setup();
      final result =
          await t.container.read(authControllerProvider.notifier).run<int>(() async => 42);
      expect(result.ok, isTrue);
      expect(result.value, 42);
    });
  });

  group('AuthController', () {
    test('sign-in with bad input reports the validation error', () async {
      final t = _setup();
      final result = await t.container
          .read(authControllerProvider.notifier)
          .signIn('not-an-email', 'x', remember: true);
      expect(result.error, contains('valid e-mail'));
      expect(t.auth.calls, isEmpty);
    });

    test('"remember me" saves the e-mail; unchecked clears it', () async {
      final t = _setup();
      final controller = t.container.read(authControllerProvider.notifier);
      await controller.signIn('a@b.rw', 'secret123', remember: true);
      expect(t.container.read(settingsControllerProvider).rememberedEmail, 'a@b.rw');
      expect(t.settings.stored.rememberedEmail, 'a@b.rw');
      await controller.signIn('a@b.rw', 'secret123', remember: false);
      expect(t.container.read(settingsControllerProvider).rememberedEmail, isEmpty);
    });

    test('backend failures become messages', () async {
      final t = _setup();
      t.auth.failWith = const AppException('Incorrect e-mail or password.');
      final result = await t.container
          .read(authControllerProvider.notifier)
          .signIn('a@b.rw', 'wrongpass1', remember: false);
      expect(result.error, 'Incorrect e-mail or password.');
    });

    test('register returns the new profile', () async {
      final t = _setup();
      final result = await t.container.read(authControllerProvider.notifier).register(
            role: Role.farmer,
            name: 'Uwase Esperance',
            email: 'e@example.com',
            phone: '0781234567',
            district: 'Huye',
            password: 'abc12345',
            confirmPassword: 'abc12345',
          );
      expect(result.ok, isTrue);
      expect(result.value!.role, Role.farmer);
      expect(t.auth.calls, contains('verify'));
    });

    test('google, reset, resend, refresh and sign out call the repository', () async {
      final t = _setup();
      final c = t.container.read(authControllerProvider.notifier);
      await c.signInWithGoogle();
      await c.sendPasswordReset('a@b.rw');
      await c.resendVerification();
      await c.refreshVerification();
      await c.signOut();
      expect(t.auth.calls, ['google', 'reset:a@b.rw', 'verify', 'reload', 'signOut']);
    });

    test('updateProfile validates', () async {
      final t = _setup();
      final c = t.container.read(authControllerProvider.notifier);
      expect((await c.updateProfile(name: '', phone: '0781234567', district: 'Huye')).ok, isFalse);
      expect((await c.updateProfile(name: 'New Name', phone: '0781234567', district: 'Huye')).ok, isTrue);
    });
  });

  group('SettingsController', () {
    test('every change is saved and visible in state', () async {
      final t = _setup();
      final c = t.container.read(settingsControllerProvider.notifier);
      await c.setTextScale(1.15);
      await c.setNotificationsEnabled(false);
      await c.setPreferredDistrict('Huye');
      await c.markOnboardingSeen();
      final s = t.container.read(settingsControllerProvider);
      expect(s.textScale, 1.15);
      expect(s.notificationsEnabled, isFalse);
      expect(s.preferredDistrict, 'Huye');
      expect(s.onboardingSeen, isTrue);
      expect(t.settings.saves, 4);
      expect(t.settings.stored.preferredDistrict, 'Huye');
    });

    test('unread badge is hidden when notifications are off', () async {
      final t = _setup();
      expect(t.container.read(unreadCountProvider), 0);
      await t.container.read(settingsControllerProvider.notifier).setNotificationsEnabled(false);
      expect(t.container.read(unreadCountProvider), 0);
    });
  });

  group('BookingController', () {
    test('books equipment for the signed-in farmer', () async {
      final t = _setup();
      await t.container.read(profileProvider.future);
      final result = await t.container.read(bookingControllerProvider.notifier).bookEquipment(
            equipment: sampleTractor,
            date: DateTime(2026, 11, 14),
            startTime: '08:00',
            durationOption: '2 hours',
            location: 'Huye',
          );
      expect(result.value, 'NTZ-2041');
      expect(t.bookings.created.single.farmerName, 'Uwase Esperance');
    });

    test('signed-out users cannot book', () async {
      final t = _setup(me: null);
      await t.container.read(profileProvider.future);
      final result = await t.container.read(bookingControllerProvider.notifier).bookEquipment(
            equipment: sampleTractor,
            date: DateTime(2026, 11, 14),
            startTime: '08:00',
            durationOption: '2 hours',
            location: 'Huye',
          );
      expect(result.ok, isFalse);
      expect(t.bookings.created, isEmpty);
    });

    test('pay, update status, delete and report', () async {
      final t = _setup();
      await t.container.read(profileProvider.future);
      final c = t.container.read(bookingControllerProvider.notifier);
      expect((await c.pay(sampleBooking(), 'MTN MoMo')).ok, isTrue);
      expect((await c.updateStatus(sampleBooking(), BookingStatus.confirmed)).ok, isTrue);
      expect((await c.delete(sampleBooking())).ok, isFalse); // still pending
      expect((await c.delete(sampleBooking(status: BookingStatus.cancelled))).ok, isTrue);
      expect((await c.reportProblem(sampleBooking(), 'short')).ok, isFalse);
      expect((await c.reportProblem(sampleBooking(), 'The machine broke down mid-job.')).ok, isTrue);
    });
  });

  group('CatalogController and AgentController', () {
    test('owner saves new equipment with their own id and name', () async {
      final t = _setup(me: sampleOwner);
      await t.container.read(profileProvider.future);
      final result = await t.container.read(catalogControllerProvider.notifier).saveEquipment(
            name: 'Water Pump',
            type: 'Pump',
            priceText: '8,000',
            unit: 'hour',
            district: 'Bugesera',
            sector: 'Nyamata',
            about: 'Petrol pump',
          );
      expect(result.ok, isTrue);
      final saved = t.catalog.added.single;
      expect(saved.ownerId, 'owner1');
      expect(saved.ownerName, 'Agasaro Farm');
      expect(saved.price, 8000);
    });

    test('editing updates the existing machine', () async {
      final t = _setup(me: sampleOwner);
      await t.container.read(profileProvider.future);
      final result = await t.container.read(catalogControllerProvider.notifier).saveEquipment(
            existing: sampleTractor,
            name: 'Tractor 60HP',
            type: 'Tractor',
            priceText: '30000',
            unit: 'hour',
            district: 'Huye',
            sector: 'Mbazi',
            about: '',
          );
      expect(result.ok, isTrue);
      expect(t.catalog.updated.single.name, 'Tractor 60HP');
      expect(t.catalog.updated.single.id, 'eq1');
    });

    test('invalid equipment is rejected', () async {
      final t = _setup(me: sampleOwner);
      await t.container.read(profileProvider.future);
      final result = await t.container.read(catalogControllerProvider.notifier).saveEquipment(
            name: '',
            type: 'Pump',
            priceText: '8000',
            unit: 'hour',
            district: 'Huye',
            sector: '',
            about: '',
          );
      expect(result.ok, isFalse);
      expect(t.catalog.added, isEmpty);
    });

    test('delete, status change and availability', () async {
      final t = _setup(me: sampleOwner);
      final c = t.container.read(catalogControllerProvider.notifier);
      expect((await c.deleteEquipment(sampleTractor)).ok, isTrue);
      expect((await c.setEquipmentStatus(sampleTractor, EquipmentStatus.maintenance)).ok, isTrue);
      const expert = Expert(id: 'ex1', name: 'Dr', field: 'f', category: 'c');
      expect((await c.saveAvailability(expert)).ok, isTrue);
    });

    test('agent saves and deletes clients', () async {
      final t = _setup(me: const AppUser(uid: 'agent1', name: 'Agent', role: Role.agent, status: 'active'));
      final c = t.container.read(agentControllerProvider.notifier);
      final saved = await c.saveClient(name: 'Mukamana Aline', phone: '0781234567', district: 'Huye');
      expect(saved.ok, isTrue);
      expect(t.agents.added.single.agentId, 'agent1');
      expect((await c.saveClient(name: 'X', phone: '1', district: '')).ok, isFalse);
      expect((await c.deleteClient(t.agents.added.single)).ok, isTrue);
    });
  });

  group('providers', () {
    test('equipmentByIdProvider and myEquipmentProvider read from the catalogue', () async {
      final t = _setup(me: sampleOwner);
      t.catalog.added.add(sampleTractor);
      await t.container.read(equipmentProvider.future);
      expect(t.container.read(equipmentByIdProvider('eq1'))?.name, 'Tractor 50HP');
      expect(t.container.read(equipmentByIdProvider('nope')), isNull);
      expect(t.container.read(myEquipmentProvider).length, 1);
    });

    test('bookingByRefProvider finds bookings in any list', () async {
      final t = _setup();
      t.bookings.farmerBookings = [sampleBooking()];
      await t.container.read(bookingsProvider.future);
      expect(t.container.read(bookingByRefProvider('NTZ-2041'))?.title, 'Tractor 50HP');
      expect(t.container.read(bookingByRefProvider('missing')), isNull);
    });
  });
}
