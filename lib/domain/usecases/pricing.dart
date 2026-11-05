import '../entities/booking.dart';

/// Result of pricing a booking.
class BookingQuote {
  const BookingQuote({required this.quantity, required this.subtotal, required this.fee});

  final int quantity;
  final int subtotal;
  final int fee;
  int get total => subtotal + fee;
}

/// Pure pricing and reporting rules — no Flutter or Firebase imports, so they
/// are easy to unit test.
class BookingPricing {
  BookingPricing._();

  /// NTIZA's fee added on top of the hire price.
  static const serviceFeeRate = 0.02;

  /// Share of every completed job kept by the platform.
  static const platformCommission = 0.10;

  /// Share of a completed job paid to the agent who booked it.
  static const agentCommission = 0.05;

  static BookingQuote quote({required int price, required int quantity}) {
    final subtotal = price * quantity;
    return BookingQuote(
      quantity: quantity,
      subtotal: subtotal,
      fee: (subtotal * serviceFeeRate).round(),
    );
  }

  /// Choices offered on the booking screen, e.g. `2 hours`, `4 hours`.
  static List<String> durationOptions(String unit) => switch (unit) {
        'hour' => ['2 hours', '4 hours', '6 hours', '8 hours'],
        'day' => ['1 day', '2 days', '3 days', '5 days'],
        _ => ['1 ha', '2 ha', '3 ha', '5 ha'],
      };

  /// The index of the option that is pre-selected.
  static int defaultDurationIndex(String unit) => unit == 'hour' ? 2 : 1;

  /// `4 hours` → 4.
  static int quantityOf(String option) => int.tryParse(option.split(' ').first) ?? 1;

  /// What the owner or expert receives after the platform's commission.
  static int providerNet(int total) => (total * (1 - platformCommission)).round();

  static int agentEarning(int total) => (total * agentCommission).round();
}

/// One bar of an earnings chart.
class MonthTotal {
  const MonthTotal(this.label, this.amount);
  final String label;
  final int amount;
}

/// Aggregates for dashboards and charts, computed from real bookings.
class BookingStats {
  BookingStats._();

  static int count(Iterable<Booking> list, String status) =>
      list.where((b) => b.status == status).length;

  /// Sum of [value] over completed bookings.
  static int completedTotal(Iterable<Booking> list, int Function(Booking) value) =>
      list.where((b) => b.status == BookingStatus.completed).fold(0, (s, b) => s + value(b));

  /// Totals for the last [months] months (oldest first) ending at [now].
  static List<MonthTotal> monthly(
    Iterable<Booking> list,
    int Function(Booking) value, {
    required DateTime now,
    int months = 6,
  }) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final result = <MonthTotal>[];
    for (var i = months - 1; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      final sum = list
          .where((b) =>
              b.status == BookingStatus.completed &&
              b.createdAt != null &&
              b.createdAt!.year == m.year &&
              b.createdAt!.month == m.month)
          .fold<int>(0, (s, b) => s + value(b));
      result.add(MonthTotal(names[m.month - 1], sum));
    }
    return result;
  }

  /// Heights for a bar chart: never all zero so the chart still draws.
  static List<double> chartValues(List<MonthTotal> series) {
    final values = [for (final m in series) m.amount.toDouble()];
    if (values.every((v) => v == 0)) return [for (final _ in values) 0.0001];
    return values;
  }
}
