import '../entities/app_user.dart';

/// Sign-in, sign-up and profile storage. Implemented with Firebase in the data layer.
abstract class AuthRepository {
  /// Emits the current identity, or `null` when signed out.
  Stream<AuthSession?> watchSession();

  /// Emits the profile document of [uid] (`null` if it does not exist yet).
  Stream<AppUser?> watchProfile(String uid);

  Future<void> signInWithEmail(String email, String password);

  /// Creates the Firebase account and returns its identity.
  Future<AuthSession> registerWithEmail(String email, String password);

  Future<void> signInWithGoogle();

  Future<void> sendPasswordReset(String email);

  Future<void> sendEmailVerification();

  /// Re-reads the account so a freshly verified e-mail is noticed.
  Future<void> reloadSession();

  Future<void> signOut();

  /// Creates or replaces the profile document.
  Future<void> saveProfile(AppUser profile);

  Future<void> updateProfile(String uid, {String? name, String? phone, String? district});
}
