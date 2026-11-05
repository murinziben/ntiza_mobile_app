import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/usecases/pricing.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';
import '../common/role_widgets.dart';

/// Helpers shared by the owner and expert screens (both are "providers" of a
/// service and see the bookings assigned to them).

/// Changes a booking's status through the controller and tells the user.
Future<void> changeBookingStatus(
  BuildContext context,
  WidgetRef ref,
  Booking booking,
  String status,
  String successMessage,
) async {
  final result = await ref.read(bookingControllerProvider.notifier).updateStatus(booking, status);
  if (!context.mounted) return;
  showToast(context, result.ok ? successMessage : result.error!);
}

/// Net earnings and the six-month chart series for a list of bookings.
/// All arithmetic lives in the domain layer ([BookingStats], [BookingPricing]).
class EarningsView {
  const EarningsView({required this.net, required this.series});

  factory EarningsView.from(List<Booking> bookings, {DateTime? now}) {
    int net(Booking b) => BookingPricing.providerNet(b.total);
    return EarningsView(
      net: BookingStats.completedTotal(bookings, net),
      series: BookingStats.monthly(bookings, net, now: now ?? DateTime.now()),
    );
  }

  final int net;
  final List<MonthTotal> series;

  List<String> get labels => [for (final m in series) m.label];
  List<double> get values => BookingStats.chartValues(series);
  int get sixMonthTotal => series.fold(0, (sum, m) => sum + m.amount);
}

/// Transaction rows (newest first) for completed bookings.
List<RowSpec> payoutRows(List<Booking> bookings, IconData icon, {int limit = 10}) => [
      for (final b in bookings.where((b) => b.status == BookingStatus.completed).take(limit))
        RowSpec(
          icon,
          b.customerName.isEmpty ? b.title : '${b.title} · ${b.customerName}',
          '${b.dateLabel} · ${b.paidVia ?? 'Not paid yet'}',
          '+${rwf(BookingPricing.providerNet(b.total))}',
        ),
    ];

/// Centered grey message for empty lists.
class EmptyNote extends StatelessWidget {
  const EmptyNote(this.text, {super.key, this.padding = 40});
  final String text;
  final double padding;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: padding, horizontal: 12),
        child: Center(
          child: Text(text,
              textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
        ),
      );
}
