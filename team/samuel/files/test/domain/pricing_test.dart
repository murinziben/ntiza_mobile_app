import 'package:flutter_test/flutter_test.dart';
import 'package:ntiza/domain/entities/entities.dart';
import 'package:ntiza/domain/usecases/pricing.dart';

import '../helpers/fakes.dart';

void main() {
  group('BookingPricing', () {
    test('adds a 2% service fee to the subtotal', () {
      final q = BookingPricing.quote(price: 25000, quantity: 6);
      expect(q.subtotal, 150000);
      expect(q.fee, 3000);
      expect(q.total, 153000);
      expect(q.quantity, 6);
    });

    test('duration options depend on the pricing unit', () {
      expect(BookingPricing.durationOptions('hour').first, '2 hours');
      expect(BookingPricing.durationOptions('day').first, '1 day');
      expect(BookingPricing.durationOptions('hectare').last, '5 ha');
    });

    test('quantityOf reads the number from an option', () {
      expect(BookingPricing.quantityOf('4 hours'), 4);
      expect(BookingPricing.quantityOf('5 ha'), 5);
      expect(BookingPricing.quantityOf('many'), 1);
    });

    test('default duration index is the third hour option or second area option', () {
      expect(BookingPricing.defaultDurationIndex('hour'), 2);
      expect(BookingPricing.defaultDurationIndex('hectare'), 1);
    });

    test('providers keep 90% and agents earn 5%', () {
      expect(BookingPricing.providerNet(100000), 90000);
      expect(BookingPricing.agentEarning(100000), 5000);
    });
  });

  group('BookingStats', () {
    final now = DateTime(2026, 11, 15);
    final list = [
      sampleBooking(ref: 'A', status: BookingStatus.completed, total: 100000, createdAt: DateTime(2026, 11, 2)),
      sampleBooking(ref: 'B', status: BookingStatus.completed, total: 50000, createdAt: DateTime(2026, 10, 20)),
      sampleBooking(ref: 'C', status: BookingStatus.pending, total: 70000, createdAt: DateTime(2026, 11, 3)),
      sampleBooking(ref: 'D', status: BookingStatus.completed, total: 30000, createdAt: DateTime(2025, 1, 3)),
    ];

    test('counts by status', () {
      expect(BookingStats.count(list, BookingStatus.completed), 3);
      expect(BookingStats.count(list, BookingStatus.pending), 1);
      expect(BookingStats.count(list, BookingStatus.cancelled), 0);
    });

    test('completedTotal ignores unfinished bookings', () {
      expect(BookingStats.completedTotal(list, (b) => b.total), 180000);
    });

    test('monthly groups completed bookings into the last six months', () {
      final series = BookingStats.monthly(list, (b) => b.total, now: now);
      expect(series.length, 6);
      expect(series.first.label, 'Jun');
      expect(series.last.label, 'Nov');
      expect(series.last.amount, 100000);
      expect(series[4].amount, 50000);
      // The January 2025 booking is outside the window.
      expect(series.fold<int>(0, (s, m) => s + m.amount), 150000);
    });

    test('monthly crosses a year boundary', () {
      final series = BookingStats.monthly([], (b) => 0, now: DateTime(2026, 2, 10));
      expect(series.map((m) => m.label).toList(), ['Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb']);
    });

    test('chartValues never returns an all-zero series', () {
      final empty = BookingStats.chartValues(BookingStats.monthly([], (b) => 0, now: now));
      expect(empty.every((v) => v > 0), isTrue);
      final real = BookingStats.chartValues(BookingStats.monthly(list, (b) => b.total, now: now));
      expect(real.last, 100000);
    });
  });
}
