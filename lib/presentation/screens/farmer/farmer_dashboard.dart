import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/usecases/pricing.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';
import '../public/widgets.dart';
import 'booking_row.dart';

/// Farmer home: greeting, live booking statistics and shortcuts.
class FarmerDashboard extends ConsumerWidget {
  const FarmerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingsProvider).valueOrNull ?? const <Booking>[];
    final courses = ref.watch(coursesProvider).valueOrNull ?? const <Course>[];
    final me = ref.watch(profileProvider).valueOrNull;

    // All numbers come from the farmer's real bookings (BookingStats is domain code).
    final pending = BookingStats.count(bookings, BookingStatus.pending);
    final confirmed = BookingStats.count(bookings, BookingStatus.confirmed);
    final completed = BookingStats.count(bookings, BookingStatus.completed);
    final spent = BookingStats.completedTotal(bookings, (b) => b.total);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                InitialsAvatar(initialsOf(me?.name ?? 'N'),
                    size: 54, bg: AppColors.primary, fg: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Muraho, ${me?.firstName ?? 'farmer'} 👋',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      Text('Farmer · ${me?.district ?? ''}',
                          style: const TextStyle(fontSize: 14, color: AppColors.muted)),
                    ],
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Notifications',
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => context.push('/notifications'),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(child: BellIcon()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColors.primaryDark, borderRadius: BorderRadius.circular(22)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Harvest season is here',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                height: 1.2,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        const Text("Book a combine harvester before it's fully booked.",
                            style: TextStyle(color: Colors.white, fontSize: 13.5)),
                        const SizedBox(height: 12),
                        OutlineButtonX('Book Now',
                            height: 48,
                            expand: false,
                            onPressed: () => context.go('/farmer/book')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const AssetPhoto('harvester.jpg', width: 92, height: 120, radius: 16),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: _Stat('${pending + confirmed}', 'Active Bookings',
                      Icons.calendar_today_outlined, AppColors.green100, AppColors.primaryDark)),
              const SizedBox(width: 14),
              Expanded(
                  child: _Stat('$pending', 'Pending', Icons.schedule, AppColors.amberBg,
                      AppColors.amberText)),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                  child: _Stat('$completed', 'Completed', Icons.check_circle_outline,
                      AppColors.blueBg, AppColors.blue)),
              const SizedBox(width: 14),
              Expanded(
                  child: _Stat(compactRwf(spent), 'Spent (RWF)', Icons.payments_outlined,
                      AppColors.purpleBg, AppColors.purple)),
            ]),
            const SizedBox(height: 24),
            const Text('Quick Actions',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: _Action('Book Equipment', Icons.agriculture_outlined,
                        () => context.go('/farmer/book'))),
                const SizedBox(width: 12),
                Expanded(
                    child: _Action('Book Expert', Icons.groups_2_outlined,
                        () => context.push('/experts'))),
                const SizedBox(width: 12),
                Expanded(
                    child: _Action('Training', Icons.menu_book_outlined,
                        () => context.go('/farmer/learn'))),
              ],
            ),
            const SizedBox(height: 24),
            SectionHeader('Recent Bookings',
                action: 'View all', onAction: () => context.go('/farmer/bookings')),
            const SizedBox(height: 12),
            if (bookings.isEmpty)
              const EmptyNote('No bookings yet — book your first machine.'),
            for (final b in bookings.take(3)) ...[
              BookingRow(
                  booking: b,
                  subtitle: b.expert
                      ? 'Consultation · ${b.dateLabel} · ${b.detail}'
                      : '${b.dateLabel} · ${b.detail} · ${b.place}'),
              const SizedBox(height: 12),
            ],
            if (courses.isNotEmpty) ...[
              const SizedBox(height: 12),
              SectionHeader('Continue Learning',
                  action: 'All courses', onAction: () => context.go('/farmer/learn')),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.all(14),
                onTap: () => context.go('/farmer/learn'),
                child: Row(
                  children: [
                    AssetPhoto(courses.first.image, width: 82, height: 70, radius: 12),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(courses.first.title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text('${courses.first.lessons} lessons · ${courses.first.level}',
                              style: const TextStyle(fontSize: 14, color: AppColors.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Number + label statistic card.
class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label, this.icon, this.bg, this.fg);
  final String value, label;
  final IconData icon;
  final Color bg, fg;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconTile(icon, bg: bg, fg: fg, size: 44, radius: 13),
            const SizedBox(height: 14),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 14.5, color: AppColors.muted)),
          ],
        ),
      );
}

/// Square shortcut card; grows with the text instead of using a fixed height.
class _Action extends StatelessWidget {
  const _Action(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 100),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconTile(icon, bg: AppColors.green50, size: 52, radius: 16),
              const SizedBox(height: 10),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}
