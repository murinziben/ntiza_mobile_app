import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/role.dart';
import '../providers/data_providers.dart';
import '../providers/dependencies.dart';
import 'action_notifier.dart';
import 'settings_controller.dart';

/// Sign-in, sign-up, verification and profile actions.
///
/// Navigation after these actions is handled by the router's redirect, which
/// reacts to the session and profile streams.
class AuthController extends ActionNotifier {
  Future<ActionResult<void>> signIn(String email, String password, {required bool remember}) =>
      run(() async {
        await ref.read(authUseCasesProvider).signIn(email, password);
        await ref.read(settingsControllerProvider.notifier).setRememberedEmail(remember ? email : '');
      });

  Future<ActionResult<AppUser>> register({
    required Role role,
    required String name,
    required String email,
    required String phone,
    required String district,
    required String password,
    required String confirmPassword,
  }) =>
      run(() => ref.read(authUseCasesProvider).register(
            role: role,
            name: name,
            email: email,
            phone: phone,
            district: district,
            password: password,
            confirmPassword: confirmPassword,
          ));

  Future<ActionResult<void>> signInWithGoogle() =>
      run(() => ref.read(authUseCasesProvider).signInWithGoogle());

  Future<ActionResult<void>> sendPasswordReset(String email) =>
      run(() => ref.read(authUseCasesProvider).sendPasswordReset(email));

  Future<ActionResult<void>> resendVerification() =>
      run(() => ref.read(authRepositoryProvider).sendEmailVerification());

  /// Re-checks the e-mail verification flag; the router moves on if it is set.
  Future<ActionResult<void>> refreshVerification() =>
      run(() => ref.read(authRepositoryProvider).reloadSession());

  /// Finishes a Google sign-up by creating the profile.
  Future<ActionResult<AppUser>> completeProfile({
    required Role role,
    required String name,
    required String phone,
    required String district,
  }) =>
      run(() async {
        final session = ref.read(sessionProvider).valueOrNull;
        if (session == null) throw const AppException('Please log in again.');
        return ref.read(authUseCasesProvider).completeProfile(
              session: session,
              role: role,
              name: name,
              phone: phone,
              district: district,
            );
      });

  Future<ActionResult<void>> updateProfile({
    required String name,
    required String phone,
    required String district,
  }) =>
      run(() async {
        final uid = ref.read(currentUidProvider);
        if (uid == null) throw const AppException('Please log in again.');
        await ref
            .read(authUseCasesProvider)
            .updateProfile(uid, name: name, phone: phone, district: district);
      });

  Future<ActionResult<void>> signOut() =>
      run(() => ref.read(authRepositoryProvider).signOut());
}

final authControllerProvider =
    NotifierProvider<AuthController, ActionState>(AuthController.new);
