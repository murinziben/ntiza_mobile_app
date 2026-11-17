/// Input validation shared by every form. Each method returns an error
/// message, or `null` when the value is acceptable (the contract of
/// `TextFormField.validator`).
class Validators {
  Validators._();

  static final _emailPattern = RegExp(r'^[\w.+\-]+@[\w\-]+(\.[\w\-]+)+$');

  /// Rwandan mobile numbers: 07X XXX XXXX or +250 7X XXX XXXX.
  static final _phonePattern = RegExp(r'^(?:\+?250|0)?7[2389]\d{7}$');

  static String? required(String? value, [String label = 'This field']) =>
      (value == null || value.trim().isEmpty) ? '$label is required.' : null;

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your e-mail address.';
    if (!_emailPattern.hasMatch(v)) return 'Enter a valid e-mail, e.g. name@example.com.';
    return null;
  }

  /// At least 8 characters with a letter and a digit.
  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Enter a password.';
    if (v.length < 8) return 'Use at least 8 characters.';
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'Include at least one letter and one number.';
    }
    return null;
  }

  /// Sign-in only checks that something was typed; strength rules apply on sign-up.
  static String? loginPassword(String? value) =>
      (value == null || value.isEmpty) ? 'Enter your password.' : null;

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Re-enter your password.';
    return value == original ? null : 'Passwords do not match.';
  }

  static String? fullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your full name.';
    if (v.length < 3) return 'Name is too short.';
    return null;
  }

  static String? phone(String? value) {
    final v = (value ?? '').replaceAll(RegExp(r'[\s\-]'), '');
    if (v.isEmpty) return 'Enter your phone number.';
    if (!_phonePattern.hasMatch(v)) return 'Enter a valid Rwandan number, e.g. 078 123 4567.';
    return null;
  }

  static String? district(String? value) =>
      (value == null || value.isEmpty) ? 'Select your district.' : null;

  /// A whole number of francs greater than zero (commas and spaces allowed).
  static String? price(String? value) {
    final n = parseAmount(value);
    if (value == null || value.trim().isEmpty) return 'Enter a price.';
    if (n == null || n <= 0) return 'Enter a price greater than zero.';
    return null;
  }

  /// Parses `25,000` or `25 000` into 25000; `null` if there are no digits.
  static int? parseAmount(String? value) =>
      int.tryParse((value ?? '').replaceAll(RegExp(r'[^0-9]'), ''));

  static String? reason(String? value) {
    final v = value?.trim() ?? '';
    if (v.length < 10) return 'Please describe the problem (at least 10 characters).';
    return null;
  }
}

/// Normalises a phone number to the `07XXXXXXXX` form used throughout the app.
String normalizePhone(String raw) {
  var d = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (d.startsWith('250')) d = d.substring(3);
  if (!d.startsWith('0')) d = '0$d';
  return d;
}
