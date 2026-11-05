import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/usecases/pricing.dart';
import '../../../domain/validators.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';
import '../common/role_widgets.dart';
import '../owner/provider_helpers.dart';
import '../public/public_shell.dart';

const expertNav = [
  NavItem('Home', Icons.grid_view_outlined),
  NavItem('Consults', Icons.chat_bubble_outline),
  NavItem('Schedule', Icons.calendar_today_outlined),
  NavItem('Earnings', Icons.payments_outlined),
  NavItem('Profile', Icons.person_outline),
];

/// Consultation bookings assigned to the signed-in expert.
final _consultsProvider = Provider.autoDispose<List<Booking>>((ref) {
  final all = ref.watch(providerBookingsProvider).valueOrNull ?? const <Booking>[];
  return [for (final b in all) if (b.expert) b];
});

final _consultFilterProvider = StateProvider.autoDispose<String>((ref) => 'Upcoming');

List<Booking> _withStatus(List<Booking> list, String status) =>
    [for (final b in list) if (b.status == status) b];

// ---------------------------------------------------------------------------
// Dashboard
// ---------------------------------------------------------------------------

/// Expert home: next consultation, key numbers and new requests.
class ExpertDashboard extends ConsumerWidget {
  const ExpertDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consults = ref.watch(_consultsProvider);
    final expert = ref.watch(myExpertProvider);
    final confirmed = _withStatus(consults, BookingStatus.confirmed);
    final pending = _withStatus(consults, BookingStatus.pending);
    final completed = BookingStats.count(consults, BookingStatus.completed);
    final earnings = EarningsView.from(consults);
    final rating = (expert?.rating ?? 0) > 0 ? expert!.rating.toStringAsFixed(1) : '–';
    // `scheduled` is a display label, so the oldest confirmed request (the
    // last in the newest-first list) stands in for "next".
    final next = confirmed.isEmpty ? null : confirmed.last;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const RoleHeader(),
            const SizedBox(height: 16),
            _NextConsultCard(booking: next),
            const SizedBox(height: 16),
            StatGrid([
              StatSpec('$completed', 'Total Consultations', Icons.chat_bubble_outline,
                  AppColors.green100, AppColors.primaryDark),
              StatSpec('${confirmed.length}', 'Upcoming', Icons.calendar_today_outlined,
                  AppColors.blueBg, AppColors.blue),
              StatSpec(rating, 'Average Rating', Icons.star, AppColors.amberBg,
                  AppColors.amberText),
              StatSpec(compactRwf(earnings.net), 'Total Earnings (RWF)',
                  Icons.payments_outlined, AppColors.purpleBg, AppColors.purple),
            ]),
            const SizedBox(height: 24),
            sectionTitle('New requests',
                action: 'View all', onAction: () => context.go('/expert/consults')),
            const SizedBox(height: 12),
            _RequestList(requests: pending.take(3).toList()),
          ],
        ),
      ),
    );
  }
}

/// Green card for the next confirmed consultation, or a friendly empty card.
class _NextConsultCard extends ConsumerWidget {
  const _NextConsultCard({required this.booking});
  final Booking? booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = booking;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: AppColors.primaryDark, borderRadius: BorderRadius.circular(22)),
      child: b == null
          ? const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next consultation',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                SizedBox(height: 10),
                Text('No consultations scheduled',
                    style: TextStyle(
                        color: Colors.white, fontSize: 21, fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text('Accepted requests will show up here.',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Next consultation',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 10),
                Text('${b.customerName} — ${b.title}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        height: 1.25,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Row(children: [
                  const Icon(Icons.schedule, size: 18, color: Color(0xFFFCD34D)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${b.scheduled} · ${b.detail}',
                        style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                ]),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlineButtonX('Cancel',
                          height: 48,
                          onPressed: () => changeBookingStatus(
                              context, ref, b, BookingStatus.cancelled, 'Consultation cancelled.')),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton('Mark Complete',
                          height: 48,
                          onPressed: () => changeBookingStatus(
                              context, ref, b, BookingStatus.completed, 'Consultation completed.')),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

/// Pending consultation requests with Decline / Accept.
class _RequestList extends ConsumerWidget {
  const _RequestList({required this.requests});
  final List<Booking> requests;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
        children: [
          if (requests.isEmpty) const EmptyNote('No new requests.', padding: 24),
          for (final r in requests) ...[
            RequestCard(
              initials: initialsOf(r.customerName),
              title: r.customerName,
              lines: [r.title, r.scheduled],
              tag: r.title,
              tags: [tagChip(r.detail), const StatusChip('Pending')],
              declineLabel: 'Decline',
              acceptLabel: 'Accept',
              onDecline: () => changeBookingStatus(
                  context, ref, r, BookingStatus.cancelled, 'Request declined.'),
              onAccept: () => changeBookingStatus(
                  context, ref, r, BookingStatus.confirmed, 'Consultation accepted.'),
            ),
            const SizedBox(height: 12),
          ],
        ],
      );
}

// ---------------------------------------------------------------------------
// Consultations
// ---------------------------------------------------------------------------

/// Upcoming / Requests / Completed / Cancelled consultations.
class ExpertConsultsScreen extends ConsumerWidget {
  const ExpertConsultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(_consultFilterProvider);
    final all = ref.watch(_consultsProvider);
    final status = switch (filter) {
      'Requests' => BookingStatus.pending,
      'Completed' => BookingStatus.completed,
      'Cancelled' => BookingStatus.cancelled,
      _ => BookingStatus.confirmed,
    };
    final shown = _withStatus(all, status);
    return Scaffold(
      appBar: const TopBar('Consultations', back: false),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          ChipRow(
            labels: const ['Upcoming', 'Requests', 'Completed', 'Cancelled'],
            selected: filter,
            onSelected: (v) => ref.read(_consultFilterProvider.notifier).state = v,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: filter == 'Requests'
                ? _RequestList(requests: shown)
                : Column(
                    children: [
                      if (shown.isEmpty) const EmptyNote('Nothing here yet.', padding: 60),
                      for (final c in shown) ...[
                        PersonCard(
                          initials: initialsOf(c.customerName),
                          name: c.customerName,
                          accent: c.title,
                          meta: c.scheduled,
                          star: false,
                          tags: [tagChip(c.detail), StatusChip(c.status)],
                          action: c.status == BookingStatus.confirmed ? 'Complete' : null,
                          onAction: () => changeBookingStatus(
                              context, ref, c, BookingStatus.completed, 'Consultation completed.'),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Availability
// ---------------------------------------------------------------------------

const _defaultHours = '08:00 – 12:00';

/// Editable copy of the expert's availability (switches only; the text
/// fields are owned by the form widget).
class _Draft {
  const _Draft({required this.accepting, required this.schedule});
  final bool accepting;
  final Map<String, String> schedule;

  _Draft copyWith({bool? accepting, Map<String, String>? schedule}) =>
      _Draft(accepting: accepting ?? this.accepting, schedule: schedule ?? this.schedule);
}

/// Seeded from the saved expert profile (keyed by expert id).
class _DraftNotifier extends AutoDisposeFamilyNotifier<_Draft, String> {
  @override
  _Draft build(String arg) {
    final expert = ref.read(expertByIdProvider(arg));
    return _Draft(
      accepting: expert?.accepting ?? true,
      schedule: expert?.fullSchedule ?? {for (final d in weekdayNames) d: ''},
    );
  }

  void setAccepting(bool value) => state = state.copyWith(accepting: value);

  void setDay(String day, bool on) {
    final next = Map<String, String>.of(state.schedule);
    next[day] = on ? _defaultHours : '';
    state = state.copyWith(schedule: next);
  }
}

final _draftProvider =
    NotifierProvider.autoDispose.family<_DraftNotifier, _Draft, String>(_DraftNotifier.new);

/// Lets the expert set weekly hours, fee and session length.
class ExpertAvailabilityScreen extends ConsumerWidget {
  const ExpertAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expert = ref.watch(myExpertProvider);
    return Scaffold(
      appBar: const TopBar('Availability', back: false),
      body: expert == null
          ? const EmptyNote(
              'Your expert profile is created when an admin approves your application.',
              padding: 80)
          : _AvailabilityForm(key: ValueKey(expert.id), expert: expert),
    );
  }
}

class _AvailabilityForm extends ConsumerStatefulWidget {
  const _AvailabilityForm({super.key, required this.expert});
  final Expert expert;

  @override
  ConsumerState<_AvailabilityForm> createState() => _AvailabilityFormState();
}

class _AvailabilityFormState extends ConsumerState<_AvailabilityForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fee;
  late final TextEditingController _minutes;

  @override
  void initState() {
    super.initState();
    _fee = TextEditingController(text: '${widget.expert.fee}');
    _minutes = TextEditingController(text: '${widget.expert.sessionMinutes}');
  }

  @override
  void dispose() {
    _fee.dispose();
    _minutes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final draft = ref.read(_draftProvider(widget.expert.id));
    final updated = widget.expert.copyWith(
      accepting: draft.accepting,
      schedule: draft.schedule,
      fee: Validators.parseAmount(_fee.text) ?? 0,
      sessionMinutes: Validators.parseAmount(_minutes.text) ?? 0,
    );
    final result = await ref.read(catalogControllerProvider.notifier).saveAvailability(updated);
    if (!mounted) return;
    showToast(context, result.ok ? 'Availability saved.' : result.error!);
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.expert.id;
    final draft = ref.watch(_draftProvider(id));
    final notifier = ref.read(_draftProvider(id).notifier);
    final busy = ref.watch(catalogControllerProvider).busy;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          AppCard(
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Accepting new consultations',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      Text('Farmers can book you',
                          style: TextStyle(fontSize: 13.5, color: AppColors.muted)),
                    ],
                  ),
                ),
                Switch(
                  value: draft.accepting,
                  activeTrackColor: AppColors.primary,
                  onChanged: notifier.setAccepting,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Weekly schedule',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              children: [
                for (final day in weekdayNames)
                  _DayRow(
                    day: day,
                    hours: draft.schedule[day] ?? '',
                    onChanged: (on) => notifier.setDay(day, on),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LabeledField('Fee per session (RWF)',
                    hint: '15,000',
                    icon: Icons.payments_outlined,
                    controller: _fee,
                    keyboard: TextInputType.number,
                    validator: Validators.price),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: LabeledField('Session (min)',
                    hint: '30',
                    icon: Icons.schedule,
                    controller: _minutes,
                    keyboard: TextInputType.number,
                    validator: (v) => Validators.required(v, 'Session length')),
              ),
            ],
          ),
          const SizedBox(height: 18),
          PrimaryButton(busy ? 'Saving…' : 'Save Availability',
              height: 54, onPressed: busy ? null : _save),
        ],
      ),
    );
  }
}

/// One weekday with its hours and an on/off switch.
class _DayRow extends StatelessWidget {
  const _DayRow({required this.day, required this.hours, required this.onChanged});
  final String day;
  final String hours;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final on = hours.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day,
                    style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        color: on ? AppColors.ink : AppColors.muted)),
                Text(on ? hours : 'Unavailable',
                    style: TextStyle(
                        fontSize: 13.5, color: on ? AppColors.primaryDark : AppColors.muted)),
              ],
            ),
          ),
          Switch(value: on, activeTrackColor: AppColors.primary, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Earnings
// ---------------------------------------------------------------------------

/// Net earnings, monthly chart and payouts from completed consultations.
class ExpertEarningsScreen extends ConsumerWidget {
  const ExpertEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consults = ref.watch(_consultsProvider);
    final earnings = EarningsView.from(consults);
    final done = BookingStats.count(consults, BookingStatus.completed);
    final rows = payoutRows(consults, Icons.chat_bubble_outline);
    return Scaffold(
      appBar: const TopBar('Earnings', back: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BalanceCard(
            label: 'Total earnings',
            amount: rwf(earnings.net),
            note: '$done completed consultations',
            button: 'Payouts via Mobile Money',
          ),
          const SizedBox(height: 16),
          BarCard(
            caption: 'Last 6 months',
            total: rwf(earnings.sixMonthTotal),
            labels: earnings.labels,
            values: earnings.values,
          ),
          const SizedBox(height: 22),
          sectionTitle('Recent payouts'),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            const EmptyNote('Completed consultations will appear here.', padding: 24)
          else
            RowsCard(rows),
        ],
      ),
    );
  }
}
