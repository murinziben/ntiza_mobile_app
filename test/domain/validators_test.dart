import 'package:flutter_test/flutter_test.dart';
import 'package:ntiza/domain/validators.dart';

void main() {
  group('Validators.email', () {
    test('accepts a normal address', () {
      expect(Validators.email('esperance@example.com'), isNull);
    });
    test('rejects empty and malformed addresses', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
      expect(Validators.email('no-at-sign'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('needs 8 characters with a letter and a digit', () {
      expect(Validators.password('abc12345'), isNull);
      expect(Validators.password('short1'), contains('8'));
      expect(Validators.password('onlyletters'), isNotNull);
      expect(Validators.password('12345678'), isNotNull);
      expect(Validators.password(''), isNotNull);
    });
    test('login only requires something to be typed', () {
      expect(Validators.loginPassword('x'), isNull);
      expect(Validators.loginPassword(''), isNotNull);
    });
    test('confirmation must match', () {
      expect(Validators.confirmPassword('abc12345', 'abc12345'), isNull);
      expect(Validators.confirmPassword('abc12346', 'abc12345'), contains('match'));
      expect(Validators.confirmPassword('', 'abc12345'), isNotNull);
    });
  });

  group('Validators.phone', () {
    test('accepts Rwandan mobile formats', () {
      expect(Validators.phone('0781234567'), isNull);
      expect(Validators.phone('078 123 4567'), isNull);
      expect(Validators.phone('+250781234567'), isNull);
      expect(Validators.phone('250 72 123 4567'), isNull);
    });
    test('rejects other numbers', () {
      expect(Validators.phone('0701234567'), isNotNull);
      expect(Validators.phone('12345'), isNotNull);
      expect(Validators.phone(''), isNotNull);
    });
    test('normalizePhone gives the 07 form', () {
      expect(normalizePhone('+250 781 234 567'), '0781234567');
      expect(normalizePhone('781234567'), '0781234567');
      expect(normalizePhone('0781234567'), '0781234567');
    });
  });

  group('other fields', () {
    test('full name needs at least three characters', () {
      expect(Validators.fullName('Eve'), isNull);
      expect(Validators.fullName('Al'), isNotNull);
      expect(Validators.fullName('  '), isNotNull);
    });
    test('required reports the label', () {
      expect(Validators.required('', 'Farm location'), contains('Farm location'));
      expect(Validators.required('x'), isNull);
    });
    test('district must be chosen', () {
      expect(Validators.district(null), isNotNull);
      expect(Validators.district('Huye'), isNull);
    });
    test('price parses commas and rejects zero', () {
      expect(Validators.parseAmount('25,000'), 25000);
      expect(Validators.parseAmount('abc'), isNull);
      expect(Validators.price('25,000'), isNull);
      expect(Validators.price('0'), isNotNull);
      expect(Validators.price(''), isNotNull);
    });
    test('problem reports need a real description', () {
      expect(Validators.reason('too short'), isNotNull);
      expect(Validators.reason('The operator never arrived.'), isNull);
    });
  });
}
