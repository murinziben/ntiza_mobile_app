import 'role.dart';

/// Account status values stored in `users.status`.
class UserStatus {
  UserStatus._();
  static const active = 'active';
  static const pending = 'pending';
  static const rejected = 'rejected';
  static const suspended = 'suspended';
}

/// The signed-in Firebase identity (not the profile document).
class AuthSession {
  const AuthSession({
    required this.uid,
    required this.email,
    required this.emailVerified,
    required this.usesPassword,
  });

  final String uid;
  final String email;
  final bool emailVerified;

  /// True for e-mail/password accounts, false for Google accounts.
  final bool usesPassword;

  /// Password accounts must confirm their e-mail before using the app.
  bool get needsVerification => usesPassword && !emailVerified;
}

/// A person's profile — the `users/{uid}` document.
class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.role,
    required this.status,
    this.phone = '',
    this.email = '',
    this.district = '',
    this.createdAt,
  });

  final String uid;
  final String name;
  final String phone;
  final String email;
  final String district;
  final String status;
  final Role role;
  final DateTime? createdAt;

  bool get isActive => status == UserStatus.active;

  /// First given name, skipping honorifics such as `Dr.`.
  String get firstName {
    final parts =
        name.split(' ').where((p) => p.isNotEmpty && !p.endsWith('.')).toList();
    return parts.isEmpty ? name : parts.first;
  }

  AppUser copyWith({
    String? name,
    String? phone,
    String? district,
    String? status,
    Role? role,
  }) =>
      AppUser(
        uid: uid,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email,
        district: district ?? this.district,
        status: status ?? this.status,
        role: role ?? this.role,
        createdAt: createdAt,
      );
}
