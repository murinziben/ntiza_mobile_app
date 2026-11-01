import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/booking/booking_screen.dart';
import '../../features/bookings/bookings_screen.dart';
import '../../features/equipment_detail/equipment_detail_screen.dart';
import '../../features/explore/explore_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../widgets/app_shell.dart';

/// Route paths, kept in one place so screens never hard-code strings.
class Routes {
  Routes._();

  static const onboarding = '/onboarding';
  static const login = '/login';
  static const home = '/home';
  static const explore = '/explore';
  static const bookings = '/bookings';
  static const notifications = '/notifications';
  static const profile = '/profile';

  static String equipment(String id) => '/equipment/$id';
  static String booking(String equipmentId) => '/booking/$equipmentId';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.onboarding,
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      // Persistent bottom nav: Home / Explore / Bookings / Alerts / Profile.
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.home, builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.explore, builder: (_, __) => const ExploreScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.bookings, builder: (_, __) => const BookingsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.notifications,
              builder: (_, __) => const NotificationsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.profile, builder: (_, __) => const ProfileScreen()),
          ]),
        ],
      ),
      // Full-screen routes: no bottom nav.
      GoRoute(
        path: '/equipment/:id',
        builder: (_, state) =>
            EquipmentDetailScreen(equipmentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/booking/:equipmentId',
        builder: (_, state) =>
            BookingScreen(equipmentId: state.pathParameters['equipmentId']!),
      ),
    ],
  );
});
