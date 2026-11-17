import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';
import '../public/widgets.dart';
import 'booking_row.dart';

const _tabs = ['Upcoming', 'Past'];

final _tabProvider = StateProvider.autoDispose<String>((ref) => 'Upcoming');

/// The farmer's bookings: open ones under Upcoming, finished ones under Past.
class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  String _subtitle(Booking b) => b.expert
      ? 'Consultation · ${b.dateLabel} · ${b.detail}'
      : '${b.dateLabel} · ${b.detail} · ${rwf(b.total)}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(_tabProvider);

    return Scaffold(
      appBar: const TopBar('My Bookings', back: false),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          ChipRow(
            labels: _tabs,
            selected: tab,
            onSelected: (v) => ref.read(_tabProvider.notifier).state = v,
          ),
          asyncSection(ref.watch(bookingsProvider), (all) {
            final items = all.where((b) => b.earlier == (tab == 'Past')).toList();
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (items.isEmpty)
                    EmptyNote(tab == 'Upcoming'
                        ? 'No upcoming bookings. Book a machine or an expert to get started.'
                        : 'No past bookings yet.'),
                  for (final b in items) ...[
                    BookingRow(booking: b, subtitle: _subtitle(b)),
                    const SizedBox(height: 12),
                  ],
                  if (items.isNotEmpty)
                    Text('${items.length} ${items.length == 1 ? 'booking' : 'bookings'}',
                        style: const TextStyle(fontSize: 13.5, color: AppColors.muted)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
