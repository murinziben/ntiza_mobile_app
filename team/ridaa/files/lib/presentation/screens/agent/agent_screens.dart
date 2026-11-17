import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/constants.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/usecases/pricing.dart';
import '../../../domain/validators.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';
import '../common/role_widgets.dart';
import '../public/public_shell.dart';

const agentNav = [
  NavItem('Home', Icons.grid_view_outlined),
  NavItem('Farmers', Icons.groups_2_outlined),
  NavItem('New Booking', Icons.add),
  NavItem('Commission', Icons.payments_outlined),
  NavItem('Profile', Icons.person_outline),
];

// ---- small shared helpers ----------------------------------------------------

/// The agent's commission on one booking (a thin wrapper over the domain rule).
int _commissionOf(Booking b) => BookingPricing.agentEarning(b.total);

/// Commission still to be earned: bookings that are not completed or cancelled.
int _pendingCommission(Iterable<Booking> list) => list
    .where((b) => b.status == BookingStatus.pending || b.status == BookingStatus.confirmed)
    .fold(0, (sum, b) => sum + _commissionOf(b));

AgentClient? _findClient(List<AgentClient> list, String? id) {
  for (final c in list) {
    if (c.id == id) return c;
  }
  return null;
}

/// Asks the user to confirm a destructive action.
Future<bool> _confirm(BuildContext context, String title, String message, String action) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(
              minimumSize: const Size(48, 48), foregroundColor: AppColors.danger),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(action),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Compact text button with an icon, at least 48dp tall.
Widget _miniAction(String label, IconData icon, VoidCallback? onTap,
        {Color color = AppColors.primaryDark}) =>
    TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(minimumSize: const Size(48, 48), foregroundColor: color),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );

// ---- dashboard -----------------------------------------------------------------

/// Agent home: commission summary, stats and the latest bookings.
class AgentDashboard extends ConsumerWidget {
  const AgentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(agentClientsProvider).valueOrNull ?? const <AgentClient>[];
    final bookings = ref.watch(agentBookingsProvider).valueOrNull ?? const <Booking>[];
    final earned = BookingStats.completedTotal(bookings, _commissionOf);
    final pending = BookingStats.count(bookings, BookingStatus.pending);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const RoleHeader(),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: SizedBox(
                height: 140,
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Container(
                        color: AppColors.primaryDark,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Pending commission',
                                style: TextStyle(color: Colors.white, fontSize: 14)),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(rwf(_pendingCommission(bookings)),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 27,
                                      fontWeight: FontWeight.w800)),
                            ),
                            const SizedBox(height: 4),
                            const Text('Paid out to Mobile Money',
                                style: TextStyle(color: Colors.white, fontSize: 13.5)),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                        flex: 5, child: AssetPhoto('hero_villagers.jpg', height: 140)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            StatGrid([
              StatSpec('${clients.length}', 'My Farmers', Icons.groups_2_outlined,
                  AppColors.green100, AppColors.primaryDark),
              StatSpec('${bookings.length}', 'Total Bookings', Icons.calendar_today_outlined,
                  AppColors.blueBg, AppColors.blue),
              StatSpec('$pending', 'Pending', Icons.schedule, AppColors.amberBg,
                  AppColors.amberText),
              StatSpec(compactRwf(earned), 'Earned to date (RWF)', Icons.show_chart,
                  AppColors.purpleBg, AppColors.purple),
            ]),
            const SizedBox(height: 16),
            PrimaryButton('+  Book for a Farmer',
                height: 54, onPressed: () => context.go('/agent/new')),
            const SizedBox(height: 24),
            sectionTitle('Recent bookings',
                action: 'Commission', onAction: () => context.go('/agent/commission')),
            const SizedBox(height: 12),
            if (bookings.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No bookings yet — book a machine for one of your farmers.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted)),
                ),
              ),
            for (final b in bookings.take(3)) ...[
              _BookingTile(booking: b),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

/// One booking the agent made, with their commission.
class _BookingTile extends StatelessWidget {
  const _BookingTile({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            AssetPhoto(booking.image, width: 60, height: 60, radius: 12),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${booking.title} · ${booking.customerName}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                      '${booking.dateLabel} · ${booking.detail} · Commission ${rwf(_commissionOf(booking))}',
                      style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusChip(booking.status),
          ],
        ),
      );
}

// ---- farmers (clients) ---------------------------------------------------------

final _clientQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// The client chosen on the Farmers tab, used by the New Booking tab. Not
/// auto-disposed: the New Booking screen may not be built yet when it is set.
final _selectedClientIdProvider = StateProvider<String?>((ref) => null);

/// Inline error shown inside the add/edit farmer dialog.
final _clientErrorProvider = StateProvider.autoDispose<String?>((ref) => null);

/// Lists the agent's farmers with add, edit, delete and "Book" actions.
class AgentFarmersScreen extends ConsumerWidget {
  const AgentFarmersScreen({super.key});

  Future<void> _openForm(BuildContext context, {AgentClient? existing}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _ClientDialog(existing: existing),
    );
    if (saved == true && context.mounted) {
      showToast(context, existing == null ? 'Farmer added.' : 'Farmer updated.');
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, AgentClient c) async {
    final ok = await _confirm(
        context, 'Delete farmer?', '${c.name} will be removed from your list.', 'Delete');
    if (!ok || !context.mounted) return;
    final result = await ref.read(agentControllerProvider.notifier).deleteClient(c);
    if (!context.mounted) return;
    showToast(context, result.ok ? 'Farmer deleted.' : result.error!);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(agentClientsProvider).valueOrNull ?? const <AgentClient>[];
    final bookings = ref.watch(agentBookingsProvider).valueOrNull ?? const <Booking>[];
    final q = ref.watch(_clientQueryProvider).trim().toLowerCase();
    final items = clients
        .where((c) => q.isEmpty || c.name.toLowerCase().contains(q) || c.phone.contains(q))
        .toList();

    return Scaffold(
      appBar: const TopBar('My Farmers', back: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          SearchField(
              hint: 'Search by name or phone',
              filter: false,
              onChanged: (v) => ref.read(_clientQueryProvider.notifier).state = v),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                    clients.isEmpty
                        ? 'No farmers yet — register your first one below.'
                        : 'No farmers match your search.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted)),
              ),
            ),
          for (final c in items) ...[
            _clientCard(context, ref, c, bookings),
            const SizedBox(height: 12),
          ],
          AppCard(
            color: AppColors.green100,
            borderColor: AppColors.green100,
            onTap: () => _openForm(context),
            child: const Center(
              child: Text('+  Register New Farmer',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _clientCard(
      BuildContext context, WidgetRef ref, AgentClient c, List<Booking> bookings) {
    final mine = bookings.where((b) => b.clientName == c.name).toList();
    final last = mine.isEmpty ? 'no bookings yet' : 'last ${mine.first.dateLabel}';
    return PersonCard(
      initials: initialsOf(c.name),
      name: c.name,
      accent: '${c.district} · ${c.phone}',
      meta: '${mine.length} bookings · $last',
      action: 'Book',
      onAction: () {
        ref.read(_selectedClientIdProvider.notifier).state = c.id;
        context.go('/agent/new');
      },
      tags: [
        _miniAction('Edit', Icons.edit_outlined, () => _openForm(context, existing: c)),
        _miniAction('Delete', Icons.delete_outline, () => _delete(context, ref, c),
            color: AppColors.danger),
      ],
    );
  }
}

/// Add / edit farmer form shown as a dialog.
class _ClientDialog extends ConsumerStatefulWidget {
  const _ClientDialog({this.existing});
  final AgentClient? existing;

  @override
  ConsumerState<_ClientDialog> createState() => _ClientDialogState();
}

class _ClientDialogState extends ConsumerState<_ClientDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _phone =
      TextEditingController(text: widget.existing?.phone ?? '');
  String? _district;

  @override
  void initState() {
    super.initState();
    final d = widget.existing?.district;
    _district = districts.contains(d) ? d : null;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    ref.read(_clientErrorProvider.notifier).state = null;
    final result = await ref.read(agentControllerProvider.notifier).saveClient(
          existing: widget.existing,
          name: _name.text,
          phone: _phone.text,
          district: _district ?? '',
        );
    if (!mounted) return;
    if (result.ok) {
      Navigator.of(context).pop(true);
    } else {
      ref.read(_clientErrorProvider.notifier).state = result.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(agentControllerProvider).busy;
    final error = ref.watch(_clientErrorProvider);
    return AlertDialog(
      title: Text(widget.existing == null ? 'Register farmer' : 'Edit farmer'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabeledField('Full name',
                  hint: 'e.g. Bizimana Jean',
                  icon: Icons.person_outline,
                  controller: _name,
                  validator: Validators.fullName,
                  textInputAction: TextInputAction.next),
              const SizedBox(height: 14),
              LabeledField('Phone number',
                  hint: '07X XXX XXXX',
                  icon: Icons.smartphone_outlined,
                  controller: _phone,
                  keyboard: TextInputType.phone,
                  validator: Validators.phone,
                  textInputAction: TextInputAction.next),
              const SizedBox(height: 14),
              const Text('District',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.body)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _district,
                isExpanded: true,
                validator: Validators.district,
                decoration: const InputDecoration(
                  hintText: 'Select district',
                  prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.muted),
                ),
                items: [for (final d in districts) DropdownMenuItem(value: d, child: Text(d))],
                onChanged: (v) => _district = v,
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error, style: const TextStyle(color: AppColors.danger, fontSize: 14)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
          onPressed: busy ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
              minimumSize: const Size(48, 48), backgroundColor: AppColors.primary),
          onPressed: busy ? null : _save,
          child: Text(busy ? 'Saving…' : 'Save'),
        ),
      ],
    );
  }
}

// ---- new booking ---------------------------------------------------------------

final _selectedEquipmentIdProvider = StateProvider<String?>((ref) => null);
final _bookingDateProvider =
    StateProvider<DateTime>((ref) => DateTime.now().add(const Duration(days: 1)));
final _startTimeProvider = StateProvider<String>((ref) => '08:00');

/// `null` means "use the default option for the machine's unit".
final _durationIndexProvider = StateProvider<int?>((ref) => null);

const _startTimes = ['06:00', '08:00', '10:00', '12:00', '14:00'];

/// Books a machine for one of the agent's farmers.
class AgentNewBookingScreen extends ConsumerStatefulWidget {
  const AgentNewBookingScreen({super.key});

  @override
  ConsumerState<AgentNewBookingScreen> createState() => _AgentNewBookingScreenState();
}

class _AgentNewBookingScreenState extends ConsumerState<AgentNewBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _location = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Arriving from the Farmers tab with a farmer already chosen.
    final clients = ref.read(agentClientsProvider).valueOrNull ?? const <AgentClient>[];
    final c = _findClient(clients, ref.read(_selectedClientIdProvider));
    if (c != null) _location.text = c.district;
  }

  @override
  void dispose() {
    _location.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = ref.read(_bookingDateProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: current.isBefore(today) ? today : current,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked != null) ref.read(_bookingDateProvider.notifier).state = picked;
  }

  Future<void> _submit(AgentClient client, Equipment equipment, String duration) async {
    if (!_formKey.currentState!.validate()) return;
    final result = await ref.read(bookingControllerProvider.notifier).bookForClient(
          equipment: equipment,
          client: client,
          date: ref.read(_bookingDateProvider),
          startTime: ref.read(_startTimeProvider),
          durationOption: duration,
          location: _location.text,
        );
    if (!mounted) return;
    if (!result.ok) {
      showToast(context, result.error!);
      return;
    }
    showToast(context, 'Booking ${result.value} sent for ${client.name}.');
    ref.invalidate(_selectedClientIdProvider);
    ref.invalidate(_selectedEquipmentIdProvider);
    ref.invalidate(_durationIndexProvider);
    _location.clear();
    context.go('/agent');
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(agentClientsProvider).valueOrNull ?? const <AgentClient>[];
    final available = [
      for (final e in ref.watch(equipmentProvider).valueOrNull ?? const <Equipment>[])
        if (e.available) e,
    ];
    final client = _findClient(clients, ref.watch(_selectedClientIdProvider));
    final equipmentId = ref.watch(_selectedEquipmentIdProvider);
    Equipment? equipment;
    for (final e in available) {
      if (e.id == equipmentId) equipment = e;
    }
    final date = ref.watch(_bookingDateProvider);
    final startTime = ref.watch(_startTimeProvider);
    final busy = ref.watch(bookingControllerProvider).busy;

    // Pre-fill the location with the farmer's district whenever the farmer changes.
    ref.listen<String?>(_selectedClientIdProvider, (_, next) {
      final c = _findClient(ref.read(agentClientsProvider).valueOrNull ?? const [], next);
      if (c != null) _location.text = c.district;
    });

    if (clients.isEmpty) {
      return Scaffold(
        appBar: const TopBar('New Booking', back: false),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              color: AppColors.green50,
              borderColor: AppColors.green100,
              child: Column(
                children: [
                  const Text('Add a farmer first',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  const Text('You book machines on behalf of the farmers on your list.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 14),
                  PrimaryButton('Go to My Farmers', onPressed: () => context.go('/agent/farmers')),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget? summary;
    String duration = '';
    if (equipment != null) {
      final options = BookingPricing.durationOptions(equipment.unit);
      final stored = ref.watch(_durationIndexProvider);
      final idx = (stored ?? BookingPricing.defaultDurationIndex(equipment.unit))
          .clamp(0, options.length - 1)
          .toInt();
      duration = options[idx];
      final quote = BookingPricing.quote(
          price: equipment.price, quantity: BookingPricing.quantityOf(duration));
      summary = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Duration',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.body)),
          const SizedBox(height: 8),
          ChipRow(
            padding: EdgeInsets.zero,
            labels: options,
            selected: duration,
            onSelected: (v) =>
                ref.read(_durationIndexProvider.notifier).state = options.indexOf(v),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration:
                BoxDecoration(color: AppColors.page, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _sumRow('Hire (${quote.quantity} × ${rwf(equipment.price)})', rwf(quote.subtotal)),
                const SizedBox(height: 10),
                _sumRow('Service fee', rwf(quote.fee)),
                const SizedBox(height: 10),
                _sumRow('Your commission (5%)', rwf(BookingPricing.agentEarning(quote.total))),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text('Farmer pays via MoMo',
                          style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 8),
                    Text(rwf(quote.total),
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark)),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    final eq = equipment;
    return Scaffold(
      appBar: const TopBar('New Booking', back: false),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            const Text('1. Farmer', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              key: ValueKey('client-${client?.id}'),
              initialValue: client?.id,
              isExpanded: true,
              decoration: const InputDecoration(
                hintText: 'Choose a farmer',
                prefixIcon: Icon(Icons.person_outline, color: AppColors.muted),
              ),
              items: [
                for (final c in clients)
                  DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.name} · ${c.district}', overflow: TextOverflow.ellipsis)),
              ],
              onChanged: (v) => ref.read(_selectedClientIdProvider.notifier).state = v,
            ),
            const SizedBox(height: 20),
            const Text('2. Machine',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            if (available.isEmpty)
              const AppCard(
                child: Text('No machines are available right now.',
                    style: TextStyle(color: AppColors.muted)),
              )
            else
              DropdownButtonFormField<String>(
                key: ValueKey('eq-${eq?.id}'),
                initialValue: eq?.id,
                isExpanded: true,
                decoration: const InputDecoration(
                  hintText: 'Choose equipment',
                  prefixIcon: Icon(Icons.agriculture_outlined, color: AppColors.muted),
                ),
                items: [
                  for (final e in available)
                    DropdownMenuItem(
                        value: e.id,
                        child: Text('${e.name} · ${rwf(e.price)}/${e.unitShort}',
                            overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (v) {
                  ref.read(_selectedEquipmentIdProvider.notifier).state = v;
                  ref.invalidate(_durationIndexProvider);
                },
              ),
            if (eq != null) ...[
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    AssetPhoto(eq.image, width: 72, height: 60, radius: 10),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(eq.name,
                              style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
                          Text('${eq.ownerName} · ${eq.place}',
                              style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Text('3. When and where',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              onTap: _pickDate,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, color: AppColors.muted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('${dayMonth(date)} ${date.year}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    const Text('Change',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Start time',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.body)),
            const SizedBox(height: 8),
            ChipRow(
              padding: EdgeInsets.zero,
              labels: _startTimes,
              selected: startTime,
              onSelected: (v) => ref.read(_startTimeProvider.notifier).state = v,
            ),
            const SizedBox(height: 14),
            LabeledField('Farm location',
                hint: 'Nyagatare · Rwempasha',
                icon: Icons.location_on_outlined,
                controller: _location,
                validator: (v) => Validators.required(v, 'Farm location')),
            const SizedBox(height: 16),
            if (summary != null) summary,
            const SizedBox(height: 16),
            PrimaryButton(busy ? 'Sending…' : 'Send Booking Request',
                height: 54,
                onPressed: (busy || client == null || eq == null)
                    ? null
                    : () => _submit(client, eq, duration)),
            if (client == null || eq == null)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text('Choose a farmer and a machine to continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.5, color: AppColors.muted)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sumRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
              child: Text(label, style: const TextStyle(fontSize: 15, color: AppColors.body))),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      );
}

// ---- commission ----------------------------------------------------------------

/// Commission totals, a six-month chart and the history of bookings.
class AgentCommissionScreen extends ConsumerWidget {
  const AgentCommissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(agentBookingsProvider).valueOrNull ?? const <Booking>[];
    final earned = BookingStats.completedTotal(bookings, _commissionOf);
    final series = BookingStats.monthly(bookings, _commissionOf, now: DateTime.now());
    final history = bookings.where((b) => b.status != BookingStatus.cancelled).toList();

    return Scaffold(
      appBar: const TopBar('Commissions', back: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BalanceCard(
            label: 'Commission earned',
            amount: rwf(earned),
            note: '5% of every completed booking',
            button: 'Paid out via Mobile Money',
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: _Tint('Pending', rwf(_pendingCommission(bookings)), AppColors.amberBg,
                      AppColors.amberText)),
              const SizedBox(width: 12),
              Expanded(
                  child: _Tint('This month', rwf(series.last.amount), AppColors.green100,
                      AppColors.primaryDark)),
            ],
          ),
          const SizedBox(height: 16),
          BarCard(
            caption: 'Commission · last 6 months',
            total: rwf(series.fold<int>(0, (s, m) => s + m.amount)),
            labels: [for (final m in series) m.label],
            values: BookingStats.chartValues(series),
          ),
          const SizedBox(height: 22),
          sectionTitle('History'),
          const SizedBox(height: 12),
          if (history.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Your commissions will appear here.',
                    style: TextStyle(color: AppColors.muted)),
              ),
            )
          else
            RowsCard([
              for (final b in history)
                RowSpec(
                  Icons.agriculture_outlined,
                  '${b.title} · ${b.customerName}',
                  '${b.dateLabel} · ${b.status.toLowerCase()}',
                  '+${rwf(_commissionOf(b)).replaceFirst('RWF ', '')}',
                  bg: b.status == BookingStatus.completed
                      ? AppColors.green100
                      : AppColors.amberBg,
                  fg: b.status == BookingStatus.completed
                      ? AppColors.primaryDark
                      : AppColors.amberText,
                  amountColor: b.status == BookingStatus.completed
                      ? AppColors.primaryDark
                      : AppColors.amberText,
                ),
            ]),
        ],
      ),
    );
  }
}

/// Small tinted summary tile.
class _Tint extends StatelessWidget {
  const _Tint(this.label, this.value, this.bg, this.fg);
  final String label, value;
  final Color bg, fg;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 14, color: fg)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.ink)),
          ],
        ),
      );
}
