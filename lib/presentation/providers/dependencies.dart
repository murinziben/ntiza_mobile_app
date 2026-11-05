import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/firebase_auth_repository.dart';
import '../../data/repositories/firestore_admin_repository.dart';
import '../../data/repositories/firestore_booking_repository.dart';
import '../../data/repositories/firestore_catalog_repository.dart';
import '../../data/repositories/firestore_notification_repository.dart';
import '../../data/repositories/prefs_settings_repository.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/agent_usecases.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/booking_usecases.dart';
import '../../domain/usecases/catalog_usecases.dart';

/// Composition root: the only place that knows which concrete classes
/// implement the domain interfaces. Tests override these providers with fakes.

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

/// Overridden in `main()` with the real instance, so settings load synchronously.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(ref.watch(firebaseAuthProvider), ref.watch(firestoreProvider)),
);
final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => FirestoreCatalogRepository(ref.watch(firestoreProvider)),
);
final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => FirestoreBookingRepository(ref.watch(firestoreProvider)),
);
final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => FirestoreNotificationRepository(ref.watch(firestoreProvider)),
);
final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => FirestoreAdminRepository(ref.watch(firestoreProvider)),
);
final agentRepositoryProvider = Provider<AgentRepository>(
  (ref) => FirestoreAgentRepository(ref.watch(firestoreProvider)),
);
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => PrefsSettingsRepository(ref.watch(sharedPreferencesProvider)),
);

final authUseCasesProvider =
    Provider<AuthUseCases>((ref) => AuthUseCases(ref.watch(authRepositoryProvider)));
final bookingUseCasesProvider = Provider<BookingUseCases>((ref) => BookingUseCases(
      ref.watch(bookingRepositoryProvider),
      ref.watch(notificationRepositoryProvider),
      ref.watch(adminRepositoryProvider),
    ));
final catalogUseCasesProvider =
    Provider<CatalogUseCases>((ref) => CatalogUseCases(ref.watch(catalogRepositoryProvider)));
final agentUseCasesProvider =
    Provider<AgentUseCases>((ref) => AgentUseCases(ref.watch(agentRepositoryProvider)));
