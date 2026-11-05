import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/entities.dart';
import '../../presentation/providers/providers.dart';
import '../../presentation/screens/admin/admin_screens.dart';
import '../../presentation/screens/agent/agent_screens.dart';
import '../../presentation/screens/auth/account_status_screen.dart';
import '../../presentation/screens/auth/complete_profile_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/guest_account_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/verify_email_screen.dart';
import '../../presentation/screens/common/edit_profile_screen.dart';
import '../../presentation/screens/common/notifications_screen.dart';
import '../../presentation/screens/common/role_widgets.dart';
import '../../presentation/screens/common/settings_screen.dart';
import '../../presentation/screens/expert/expert_screens.dart';
import '../../presentation/screens/farmer/book_equipment_screen.dart';
import '../../presentation/screens/farmer/book_expert_screen.dart';
import '../../presentation/screens/farmer/booking_detail_screen.dart';
import '../../presentation/screens/farmer/farmer_dashboard.dart';
import '../../presentation/screens/farmer/farmer_profile_screen.dart';
import '../../presentation/screens/farmer/farmer_shell.dart';
import '../../presentation/screens/farmer/my_bookings_screen.dart';
import '../../presentation/screens/farmer/payment_screen.dart';
import '../../presentation/screens/owner/owner_screens.dart';
import '../../presentation/screens/public/equipment_detail_screen.dart';
import '../../presentation/screens/public/experts_screen.dart';
import '../../presentation/screens/public/home_screen.dart';
import '../../presentation/screens/public/marketplace_screen.dart';
import '../../presentation/screens/public/public_shell.dart';
import '../../presentation/screens/public/training_screen.dart';
import '../../presentation/screens/public/welcome_screen.dart';

/// Re-runs the router's redirect whenever the session or profile changes.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(sessionProvider, (_, __) => notifyListeners());
    ref.listen(profileProvider, (_, __) => notifyListeners());
  }
}

const _roleAreas = ['/farmer', '/owner', '/agent', '/expert', '/admin'];

/// Screens only a signed-in user may open (besides the role areas).
const _needsLogin = ['/notifications', '/profile/edit'];

/// Screens that appear while an account is not yet usable.
const _gates = ['/verify-email', '/status', '/complete-profile'];

/// Screens a signed-in, active user has no reason to see.
const _entryScreens = ['/welcome', '/login', '/register', '/forgot-password', '/home'];

/// True when [loc] is [area] itself or a page below it. A plain `startsWith`
/// would wrongly treat the public `/experts` page as part of `/expert`.
bool _within(String loc, String area) => loc == area || loc.startsWith('$area/');

/// Decides where [loc] should send the user, or `null` to stay.
///
/// The order matters: signed out → e-mail not verified → no profile yet →
/// account pending/suspended → active user kept inside their own role area.
@visibleForTesting
String? decideRedirect({
  required String loc,
  required AsyncValue<AuthSession?> session,
  required AsyncValue<AppUser?> profile,
}) {
  if (session.isLoading) return null;
  final identity = session.valueOrNull;
  final inRoleArea = _roleAreas.any((a) => _within(loc, a));

  if (identity == null) {
    if (inRoleArea || _gates.contains(loc) || _needsLogin.contains(loc)) return '/login';
    return null;
  }
  if (identity.needsVerification) return loc == '/verify-email' ? null : '/verify-email';

  if (profile.isLoading) return null;
  final me = profile.valueOrNull;
  if (me == null) return loc == '/complete-profile' ? null : '/complete-profile';
  if (!me.isActive) return loc == '/status' ? null : '/status';

  if (_gates.contains(loc) || _entryScreens.contains(loc)) return me.role.home;
  if (inRoleArea && !_within(loc, me.role.home)) return me.role.home;
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);
  final seen = ref.read(settingsControllerProvider).onboardingSeen;

  return GoRouter(
    initialLocation: seen ? '/home' : '/welcome',
    refreshListenable: refresh,
    redirect: (context, state) => decideRedirect(
      loc: state.matchedLocation,
      session: ref.read(sessionProvider),
      profile: ref.read(profileProvider),
    ),
    routes: [
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/verify-email', builder: (_, __) => const VerifyEmailScreen()),
      GoRoute(path: '/status', builder: (_, __) => const AccountStatusScreen()),
      GoRoute(path: '/complete-profile', builder: (_, __) => const CompleteProfileScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfileScreen()),
      GoRoute(
        path: '/equipment/:id',
        builder: (_, s) => EquipmentDetailScreen(id: s.pathParameters['id']!),
      ),

      // Farmer flows that sit on top of the tab bar.
      GoRoute(
        path: '/farmer/book/:id',
        builder: (_, s) => BookEquipmentScreen(equipmentId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/farmer/book-expert/:id',
        builder: (_, s) => BookExpertScreen(expertId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/farmer/pay/:ref',
        builder: (_, s) => PaymentScreen(bookingRef: s.pathParameters['ref']!),
      ),
      GoRoute(
        path: '/farmer/booking/:ref',
        builder: (_, s) => BookingDetailScreen(bookingRef: s.pathParameters['ref']!),
      ),

      // Owner create / edit form.
      GoRoute(path: '/owner/equipment/new', builder: (_, __) => const EquipmentFormScreen()),
      GoRoute(
        path: '/owner/equipment/:id/edit',
        builder: (_, s) => EquipmentFormScreen(equipmentId: s.pathParameters['id']),
      ),

      _roleShell(ownerNav, const [
        ('/owner', OwnerDashboard()),
        ('/owner/equipment', OwnerEquipmentScreen()),
        ('/owner/bookings', OwnerBookingsScreen()),
        ('/owner/earnings', OwnerEarningsScreen()),
        ('/owner/profile', RoleProfileScreen()),
      ]),
      _roleShell(agentNav, const [
        ('/agent', AgentDashboard()),
        ('/agent/farmers', AgentFarmersScreen()),
        ('/agent/new', AgentNewBookingScreen()),
        ('/agent/commission', AgentCommissionScreen()),
        ('/agent/profile', RoleProfileScreen()),
      ]),
      _roleShell(expertNav, const [
        ('/expert', ExpertDashboard()),
        ('/expert/consults', ExpertConsultsScreen()),
        ('/expert/schedule', ExpertAvailabilityScreen()),
        ('/expert/earnings', ExpertEarningsScreen()),
        ('/expert/profile', RoleProfileScreen()),
      ]),
      _roleShell(adminNav, const [
        ('/admin', AdminOverview()),
        ('/admin/applications', AdminApplicationsScreen()),
        ('/admin/users', AdminUsersScreen()),
        ('/admin/disputes', AdminDisputesScreen()),
        ('/admin/more', AdminMoreScreen()),
      ]),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => FarmerShell(shell: shell),
        branches: [
          _branch('/farmer', const FarmerDashboard()),
          _branch('/farmer/book', const MarketplaceScreen()),
          _branch('/farmer/bookings', const MyBookingsScreen()),
          _branch('/farmer/learn', const TrainingScreen()),
          _branch('/farmer/profile', const FarmerProfileScreen()),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => PublicShell(shell: shell),
        branches: [
          _branch('/home', const HomeScreen()),
          _branch('/equipment', const MarketplaceScreen()),
          _branch('/experts', const ExpertsScreen()),
          _branch('/training', const TrainingScreen()),
          _branch('/account', const GuestAccountScreen()),
        ],
      ),
    ],
  );
});

StatefulShellBranch _branch(String path, Widget page) => StatefulShellBranch(
      routes: [GoRoute(path: path, builder: (_, __) => page)],
    );

RouteBase _roleShell(List<NavItem> nav, List<(String, Widget)> pages) =>
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => RoleShell(shell: shell, items: nav),
      branches: [for (final p in pages) _branch(p.$1, p.$2)],
    );
