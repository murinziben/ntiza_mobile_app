import 'package:flutter_test/flutter_test.dart';
import 'package:ntiza/core/errors/app_exception.dart';
import 'package:ntiza/core/utils/formatters.dart';

void main() {
  test('rwf groups thousands', () {
    expect(rwf(0), 'RWF 0');
    expect(rwf(999), 'RWF 999');
    expect(rwf(25000), 'RWF 25,000');
    expect(rwf(1234567), 'RWF 1,234,567');
  });

  test('initialsOf', () {
    expect(initialsOf('Uwase Esperance'), 'UE');
    expect(initialsOf('Dr. Uwera Solange'), 'US');
    expect(initialsOf('Grace'), 'G');
    expect(initialsOf('   '), '?');
  });

  test('timeAgo', () {
    final now = DateTime(2026, 11, 5, 12);
    expect(timeAgo(now.subtract(const Duration(seconds: 20)), now: now), 'now');
    expect(timeAgo(now.subtract(const Duration(minutes: 5)), now: now), '5m');
    expect(timeAgo(now.subtract(const Duration(hours: 3)), now: now), '3h');
    expect(timeAgo(now.subtract(const Duration(hours: 30)), now: now), 'Yesterday');
    expect(timeAgo(DateTime(2026, 10, 12), now: now), '12 Oct');
  });

  test('dayMonth and compactRwf', () {
    expect(dayMonth(DateTime(2026, 11, 5)), '05 Nov');
    expect(compactRwf(412000), '412K');
    expect(compactRwf(1200000), '1.20M');
  });

  test('AppException prints its message', () {
    expect(const AppException('Oops').toString(), 'Oops');
  });
}
