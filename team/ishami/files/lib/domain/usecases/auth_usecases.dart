import '../../core/errors/app_exception.dart';
import '../entities/app_user.dart';
import '../entities/role.dart';
import '../repositories/auth_repository.dart';
import '../validators.dart';

/// Sign-in and sign-up rules. Input is validated here so the UI only has to
/// show the message of the [AppException] that is thrown.
class AuthUseCases {
  AuthUseCases(this._auth);

  final AuthRepository _auth;

  Future<void> signIn(String email, String password) async {
    final error = Validators.email(email) ?? Validators.loginPassword(password);
    if (error != null) throw AppException(error);
    await _auth.signInWithEmail(email.trim(), password);
  }

  /// Creates the account and its profile, then sends the verification e-mail.
  /// Farmers are active at once; partner roles wait for admin approval.
  Future<AppUser> register({
    required Role role,
    required String name,
    required String email,
    required String phone,
    required String district,
    required String password,
    required String confirmPassword,
  }) async {
    final error = Validators.fullName(name) ??
        Validators.email(email) ??
        Validators.phone(phone) ??
        Validators.district(district) ??
        Validators.password(password) ??
        Validators.confirmPassword(confirmPassword, password);
    if (error != null) throw AppException(error);

    final session = await _auth.registerWithEmail(email.trim(), password);
    final profile = AppUser(
      uid: session.uid,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      phone: normalizePhone(phone),
      district: district,
      role: role,
      status: statusFor(role),
    );
    await _auth.saveProfile(profile);
    await _auth.sendEmailVerification();
    return profile;
  }

  Future<void> signInWithGoogle() => _auth.signInWithGoogle();

  /// Finishes a Google sign-up, which has no profile yet.
  Future<AppUser> completeProfile({
    required AuthSession session,
    required Role role,
    required String name,
    required String phone,
    required String district,
  }) async {
    final error = Validators.fullName(name) ??
        Validators.phone(phone) ??
        Validators.district(district);
    if (error != null) throw AppException(error);
    final profile = AppUser(
      uid: session.uid,
      name: name.trim(),
      email: session.email.toLowerCase(),
      phone: normalizePhone(phone),
      district: district,
      role: role,
      status: statusFor(role),
    );
    await _auth.saveProfile(profile);
    return profile;
  }

  Future<void> sendPasswordReset(String email) async {
    final error = Validators.email(email);
    if (error != null) throw AppException(error);
    await _auth.sendPasswordReset(email.trim());
  }

  Future<void> updateProfile(String uid,
      {required String name, required String phone, required String district}) async {
    final error = Validators.fullName(name) ??
        Validators.phone(phone) ??
        Validators.district(district);
    if (error != null) throw AppException(error);
    await _auth.updateProfile(uid,
        name: name.trim(), phone: normalizePhone(phone), district: district);
  }

  /// Partner roles start `pending`, everyone else `active`.
  static String statusFor(Role role) =>
      role.needsApproval ? UserStatus.pending : UserStatus.active;
}
