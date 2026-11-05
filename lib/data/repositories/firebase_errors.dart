import 'package:firebase_auth/firebase_auth.dart';

import '../../core/errors/app_exception.dart';

/// Turns a Firebase Auth error code into a message a farmer can act on.
String authMessageFor(String code) => switch (code) {
      'invalid-credential' ||
      'user-not-found' ||
      'wrong-password' =>
        'Incorrect e-mail or password.',
      'invalid-email' => 'That e-mail address is not valid.',
      'email-already-in-use' => 'An account with this e-mail already exists. Try logging in.',
      'weak-password' => 'Password is too weak. Use at least 8 characters.',
      'user-disabled' => 'This account has been disabled. Please contact support.',
      'network-request-failed' => 'No internet connection. Please try again.',
      'too-many-requests' => 'Too many attempts. Please wait a moment and try again.',
      'requires-recent-login' => 'Please log in again, then repeat this action.',
      'account-exists-with-different-credential' =>
        'This e-mail is registered with a password. Log in with your password instead.',
      'canceled' ||
      'web-context-canceled' ||
      'popup-closed-by-user' ||
      'cancelled-popup-request' =>
        'Sign-in was cancelled.',
      _ => 'Something went wrong ($code). Please try again.',
    };

/// Runs [job], converting Firebase failures into [AppException]s.
Future<T> guardAuth<T>(Future<T> Function() job) async {
  try {
    return await job();
  } on FirebaseAuthException catch (e) {
    throw AppException(authMessageFor(e.code));
  }
}

/// Runs a Firestore [job], turning permission errors into friendly text.
Future<T> guardData<T>(Future<T> Function() job) async {
  try {
    return await job();
  } on AppException {
    rethrow;
  } on FirebaseException catch (e) {
    if (e.code == 'permission-denied') {
      throw const AppException('You do not have permission to do that.');
    }
    if (e.code == 'unavailable') {
      throw const AppException('No connection to the server. Please try again.');
    }
    throw AppException('Could not save your changes (${e.code}).');
  }
}
