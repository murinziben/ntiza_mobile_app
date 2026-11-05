import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../mappers/firestore_mappers.dart';
import 'firebase_errors.dart';

/// [AuthRepository] backed by Firebase Authentication and the `users` collection.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._db);

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  AuthSession? _sessionOf(User? user) => user == null
      ? null
      : AuthSession(
          uid: user.uid,
          email: user.email ?? '',
          emailVerified: user.emailVerified,
          usesPassword: user.providerData.any((p) => p.providerId == 'password'),
        );

  @override
  Stream<AuthSession?> watchSession() => _auth.userChanges().map(_sessionOf);

  @override
  Stream<AppUser?> watchProfile(String uid) => _userDoc(uid).snapshots().map(
        (s) => s.exists ? userFromMap(s.id, s.data()!) : null,
      );

  @override
  Future<void> signInWithEmail(String email, String password) => guardAuth(
        () => _auth.signInWithEmailAndPassword(email: email, password: password),
      );

  @override
  Future<AuthSession> registerWithEmail(String email, String password) => guardAuth(() async {
        final cred =
            await _auth.createUserWithEmailAndPassword(email: email, password: password);
        return _sessionOf(cred.user)!;
      });

  @override
  Future<void> signInWithGoogle() => guardAuth(
        () => _auth.signInWithProvider(GoogleAuthProvider()),
      );

  @override
  Future<void> sendPasswordReset(String email) =>
      guardAuth(() => _auth.sendPasswordResetEmail(email: email));

  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) throw const AppException('Please log in first.');
    await guardAuth(user.sendEmailVerification);
  }

  @override
  Future<void> reloadSession() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await guardAuth(() async {
      await user.reload();
      // Forces a token refresh so listeners see the new emailVerified flag.
      await _auth.currentUser?.getIdToken(true);
    });
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> saveProfile(AppUser profile) =>
      guardData(() => _userDoc(profile.uid).set(userToMap(profile)));

  @override
  Future<void> updateProfile(String uid, {String? name, String? phone, String? district}) =>
      guardData(() => _userDoc(uid).update({
            if (name != null) 'name': name,
            if (phone != null) 'phone': phone,
            if (district != null) 'district': district,
          }));
}
