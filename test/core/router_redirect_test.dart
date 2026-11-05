import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntiza/core/router/app_router.dart';
import 'package:ntiza/domain/entities/entities.dart';

const _verified = AuthSession(uid: 'u', email: 'u@x.rw', emailVerified: true, usesPassword: true);
const _unverified = AuthSession(uid: 'u', email: 'u@x.rw', emailVerified: false, usesPassword: true);

AppUser _user(Role role, {String status = UserStatus.active}) =>
    AppUser(uid: 'u', name: 'Test User', role: role, status: status);

String? _go(String loc, {AuthSession? session, AppUser? me, bool sessionLoading = false, bool profileLoading = false}) =>
    decideRedirect(
      loc: loc,
      session: sessionLoading ? const AsyncLoading() : AsyncData(session),
      profile: profileLoading ? const AsyncLoading() : AsyncData(me),
    );

void main() {
  group('signed out', () {
    test('may browse public screens', () {
      for (final loc in ['/welcome', '/home', '/equipment', '/equipment/eq1', '/login', '/register', '/settings']) {
        expect(_go(loc), isNull, reason: loc);
      }
    });
    test('is sent to login from protected screens', () {
      for (final loc in ['/farmer', '/owner/equipment', '/admin/users', '/notifications', '/profile/edit', '/status']) {
        expect(_go(loc), '/login', reason: loc);
      }
    });
    test('waits while the session is still loading', () {
      expect(_go('/farmer', sessionLoading: true), isNull);
    });
  });

  group('signed in', () {
    test('unverified password accounts must verify first', () {
      expect(_go('/farmer', session: _unverified), '/verify-email');
      expect(_go('/verify-email', session: _unverified), isNull);
    });
    test('a Google user without a profile completes it', () {
      expect(_go('/home', session: _verified), '/complete-profile');
      expect(_go('/complete-profile', session: _verified), isNull);
    });
    test('waits while the profile loads', () {
      expect(_go('/login', session: _verified, profileLoading: true), isNull);
    });
    test('pending and suspended accounts see the status screen', () {
      expect(_go('/owner', session: _verified, me: _user(Role.owner, status: UserStatus.pending)), '/status');
      expect(_go('/status', session: _verified, me: _user(Role.owner, status: UserStatus.pending)), isNull);
      expect(_go('/farmer', session: _verified, me: _user(Role.farmer, status: UserStatus.suspended)), '/status');
    });
    test('active users leave entry screens for their own home', () {
      for (final loc in ['/welcome', '/login', '/register', '/home', '/status', '/verify-email']) {
        expect(_go(loc, session: _verified, me: _user(Role.owner)), '/owner', reason: loc);
      }
    });
    test('each role stays inside its own area', () {
      expect(_go('/admin', session: _verified, me: _user(Role.farmer)), '/farmer');
      expect(_go('/farmer/bookings', session: _verified, me: _user(Role.farmer)), isNull);
      expect(_go('/owner/equipment/new', session: _verified, me: _user(Role.owner)), isNull);
      expect(_go('/owner', session: _verified, me: _user(Role.agent)), '/agent');
      expect(_go('/notifications', session: _verified, me: _user(Role.expert)), isNull);
      expect(_go('/equipment/eq1', session: _verified, me: _user(Role.farmer)), isNull);
    });
    test('the public /experts page is not the /expert role area', () {
      expect(_go('/experts'), isNull);
      expect(_go('/experts', session: _verified, me: _user(Role.farmer)), isNull);
      expect(_go('/expert', session: _verified, me: _user(Role.farmer)), '/farmer');
    });
  });
}
