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
import 'provider_helpers.dart';

const ownerNav = [
  NavItem('Home', Icons.grid_view_outlined),
  NavItem('Equipment', Icons.agriculture_outlined),
  NavItem('Bookings', Icons.calendar_today_outlined),
  NavItem('Earnings', Icons.payments_outlined),
  NavItem('Profile', Icons.person_outline),
];

/// Bookings for the owner's machines (consultations belong to experts).
final _ownerBookingsProvider = Provider.autoDispose<List<Booking>>((ref) {
  final all = ref.watch(providerBookingsProvider).valueOrNull ?? const <Booking>[];
  return [for (final b in all) if (!b.expert) b];
});

final _equipmentFilterProvider = StateProvider.autoDispose<String>((ref) => 'All');
final _bookingFilterProvider = StateProvider.autoDispose<String>((ref) => 'Requests');

List<Booking> _withStatus(List<Booking> list, String status) =>
    [for (final b in list) if (b.status == status) b];

// ---------------------------------------------------------------------------
// Dashboard
// ---------------------------------------------------------------------------

/// Owner home: key numbers, earnings chart, pending requests, machines in repair.
class OwnerDashboard extends ConsumerWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(_ownerBookingsProvider);
    final mine = ref.watch(myEquipmentProvider);
    final requests = _withStatus(bookings, BookingStatus.pending);
    final earnings = EarningsView.from(bookings);
    final inRepair = [for (final e in mine) if (e.status == EquipmentStatus.maintenance) e];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const RoleHeader(),
            const SizedBox(height: 16),
            StatGrid([
              StatSpec('${mine.length}', 'My Equipment', Icons.agriculture_outlined,
                  AppColors.green100, AppColors.primaryDark),
              StatSpec('${mine.where((e) => e.available).length}', 'Available Now',
                  Icons.check_circle_outline, AppColors.blueBg, AppColors.blue),
              StatSpec('${requests.length}', 'Pending Requests', Icons.schedule,
                  AppColors.amberBg, AppColors.amberText),
              StatSpec(compactRwf(earnings.net), 'Total Earnings (RWF)', Icons.payments_outlined,
                  AppColors.purpleBg, AppColors.purple),
            ]),
            const SizedBox(height: 16),
            BarCard(
              caption: 'Earnings · last 6 months',
              total: rwf(earnings.sixMonthTotal),
              labels: earnings.labels,
              values: earnings.values,
            ),
            const SizedBox(height: 24),
            sectionTitle('Pending Requests',
                action: 'View all', onAction: () => context.go('/owner/bookings')),
            const SizedBox(height: 12),
            if (requests.isEmpty) const EmptyNote('No pending requests.', padding: 24),
            for (final r in requests.take(2)) ...[
              _RequestTile(booking: r),
              const SizedBox(height: 12),
            ],
            if (inRepair.isNotEmpty) ...[
              const SizedBox(height: 12),
              sectionTitle('Needs attention'),
              const SizedBox(height: 12),
              for (final e in inRepair) ...[
                _MaintenanceTile(equipment: e),
                const SizedBox(height: 12),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// Machine currently in maintenance, with a one-tap "Ready" action.
class _MaintenanceTile extends ConsumerWidget {
  const _MaintenanceTile({required this.equipment});
  final Equipment equipment;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            AssetPhoto(equipment.image, width: 60, height: 60, radius: 12),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(equipment.name,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  Text('Under maintenance · ${equipment.place}',
                      style: const TextStyle(fontSize: 13.5, color: AppColors.muted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SoftButton('Ready', onPressed: () async {
              final result = await ref
                  .read(catalogControllerProvider.notifier)
                  .setEquipmentStatus(equipment, EquipmentStatus.available);
              if (!context.mounted) return;
              showToast(context, result.ok ? 'Marked available.' : result.error!);
            }),
          ],
        ),
      );
}

/// Pending booking with Decline / Accept buttons.
class _RequestTile extends ConsumerWidget {
  const _RequestTile({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) => RequestCard(
        image: booking.image,
        title: booking.title,
        lines: [
          '${booking.customerName} · Farmer',
          '${booking.dateLabel} · ${booking.detail} · ${booking.location}',
        ],
        price: rwf(booking.total),
        declineLabel: 'Decline',
        acceptLabel: 'Accept',
        onDecline: () => changeBookingStatus(
            context, ref, booking, BookingStatus.cancelled, 'Request declined.'),
        onAccept: () => changeBookingStatus(context, ref, booking, BookingStatus.confirmed,
            'Request accepted. The farmer has been notified.'),
      );
}

// ---------------------------------------------------------------------------
// Equipment list
// ---------------------------------------------------------------------------

/// The owner's machines with filter chips and an edit / status / delete menu.
class OwnerEquipmentScreen extends ConsumerWidget {
  const OwnerEquipmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(_equipmentFilterProvider);
    final mine = ref.watch(myEquipmentProvider);
    final items = [for (final e in mine) if (filter == 'All' || e.status == filter) e];
    return Scaffold(
      appBar: const TopBar('My Equipment', back: false),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          ChipRow(
            labels: const ['All', ...EquipmentStatus.all],
            selected: filter,
            onSelected: (v) => ref.read(_equipmentFilterProvider.notifier).state = v,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                if (items.isEmpty)
                  const EmptyNote('No equipment here yet — add your first machine.'),
                for (final e in items) ...[
                  _EquipmentRow(equipment: e),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 4),
                PrimaryButton('+  Add Equipment',
                    height: 54, onPressed: () => context.push('/owner/equipment/new')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _MenuAction { edit, available, booked, maintenance, delete }

/// One machine in the list; the three-dot menu holds its CRUD actions.
class _EquipmentRow extends ConsumerWidget {
  const _EquipmentRow({required this.equipment});
  final Equipment equipment;

  Future<void> _onMenu(BuildContext context, WidgetRef ref, _MenuAction action) async {
    final controller = ref.read(catalogControllerProvider.notifier);
    switch (action) {
      case _MenuAction.edit:
        context.push('/owner/equipment/${equipment.id}/edit');
        return;
      case _MenuAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete equipment?'),
            content: Text('${equipment.name} will be removed from the marketplace.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
        final result = await controller.deleteEquipment(equipment);
        if (!context.mounted) return;
        showToast(context, result.ok ? 'Equipment deleted.' : result.error!);
      case _MenuAction.available || _MenuAction.booked || _MenuAction.maintenance:
        final status = switch (action) {
          _MenuAction.available => EquipmentStatus.available,
          _MenuAction.booked => EquipmentStatus.booked,
          _ => EquipmentStatus.maintenance,
        };
        final result = await controller.setEquipmentStatus(equipment, status);
        if (!context.mounted) return;
        showToast(context, result.ok ? 'Marked ${status.toLowerCase()}.' : result.error!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppCard(
        padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
        onTap: () => context.push('/owner/equipment/${equipment.id}/edit'),
        child: Row(
          children: [
            AssetPhoto(equipment.image, width: 64, height: 64, radius: 12),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(equipment.name,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                      '${equipment.district} · ${rwf(equipment.price)}/${equipment.unitShort} · ${equipment.jobs} jobs',
                      style: const TextStyle(fontSize: 13.5, color: AppColors.muted)),
                  const SizedBox(height: 6),
                  StatusChip(equipment.statusLabel),
                ],
              ),
            ),
            PopupMenuButton<_MenuAction>(
              tooltip: 'Equipment actions',
              icon: const Icon(Icons.more_vert, color: AppColors.muted),
              onSelected: (a) => _onMenu(context, ref, a),
              itemBuilder: (_) => [
                const PopupMenuItem(value: _MenuAction.edit, child: Text('Edit')),
                if (!equipment.available)
                  const PopupMenuItem(value: _MenuAction.available, child: Text('Mark available')),
                if (equipment.status != EquipmentStatus.booked)
                  const PopupMenuItem(value: _MenuAction.booked, child: Text('Mark booked')),
                if (equipment.status != EquipmentStatus.maintenance)
                  const PopupMenuItem(
                      value: _MenuAction.maintenance, child: Text('Mark maintenance')),
                const PopupMenuItem(value: _MenuAction.delete, child: Text('Delete')),
              ],
            ),
          ],
        ),
      );
}

// ---------------------------------------------------------------------------
// Create / edit form
// ---------------------------------------------------------------------------

/// Dropdown choices of the equipment form.
class _FormDraft {
  const _FormDraft({required this.type, required this.unit, required this.district});
  final String type;
  final String unit;
  final String district;

  _FormDraft copyWith({String? type, String? unit, String? district}) => _FormDraft(
        type: type ?? this.type,
        unit: unit ?? this.unit,
        district: district ?? this.district,
      );
}

/// Holds the dropdown selections; seeded from the machine being edited.
class _FormDraftNotifier extends AutoDisposeFamilyNotifier<_FormDraft, String?> {
  @override
  _FormDraft build(String? arg) {
    final existing = arg == null ? null : ref.read(equipmentByIdProvider(arg));
    return _FormDraft(
      type: existing?.type ?? equipmentTypes.first,
      unit: existing?.unit ?? equipmentUnits.first,
      district: existing?.district ?? '',
    );
  }

  void setType(String v) => state = state.copyWith(type: v);
  void setUnit(String v) => state = state.copyWith(unit: v);
  void setDistrict(String v) => state = state.copyWith(district: v);
}

final _formDraftProvider = NotifierProvider.autoDispose
    .family<_FormDraftNotifier, _FormDraft, String?>(_FormDraftNotifier.new);

/// Adds a machine, or edits one when [equipmentId] is given.
class EquipmentFormScreen extends ConsumerStatefulWidget {
  const EquipmentFormScreen({super.key, this.equipmentId});
  final String? equipmentId;

  @override
  ConsumerState<EquipmentFormScreen> createState() => _EquipmentFormScreenState();
}

class _EquipmentFormScreenState extends ConsumerState<EquipmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _sector;
  late final TextEditingController _about;

  @override
  void initState() {
    super.initState();
    final id = widget.equipmentId;
    final e = id == null ? null : ref.read(equipmentByIdProvider(id));
    _name = TextEditingController(text: e?.name ?? '');
    _price = TextEditingController(text: e == null ? '' : '${e.price}');
    _sector = TextEditingController(text: e?.sector ?? '');
    _about = TextEditingController(text: e?.about ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _sector.dispose();
    _about.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final id = widget.equipmentId;
    final draft = ref.read(_formDraftProvider(id));
    final existing = id == null ? null : ref.read(equipmentByIdProvider(id));
    final result = await ref.read(catalogControllerProvider.notifier).saveEquipment(
          existing: existing,
          name: _name.text,
          type: draft.type,
          priceText: _price.text,
          unit: draft.unit,
          district: draft.district,
          sector: _sector.text,
          about: _about.text,
        );
    if (!mounted) return;
    if (!result.ok) {
      showToast(context, result.error!);
      return;
    }
    showToast(context, existing == null ? 'Equipment saved.' : 'Equipment updated.');
    context.pop();
  }

  static String _capital(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Widget _dropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> options,
    required ValueChanged<String> onChanged,
    String? Function(String?)? validator,
    String Function(String)? display,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.body)),
          ),
          DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            validator: validator,
            decoration: InputDecoration(prefixIcon: Icon(icon, color: AppColors.muted)),
            items: [
              for (final o in options)
                DropdownMenuItem(value: o, child: Text(display == null ? o : display(o))),
            ],
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final id = widget.equipmentId;
    final editing = id != null;
    final draft = ref.watch(_formDraftProvider(id));
    final notifier = ref.read(_formDraftProvider(id).notifier);
    final busy = ref.watch(catalogControllerProvider).busy;
    final districtOptions = {
      ...districts,
      if (draft.district.isNotEmpty) draft.district,
    }.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TopBar(editing ? 'Edit Equipment' : 'Add Equipment'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            // The photo comes from the machine type, so this is a preview only.
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.green50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  AssetPhoto(imageForType(draft.type), width: 84, height: 72, radius: 12),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Photo is chosen from the machine type',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark)),
                        SizedBox(height: 2),
                        Text('Pick the type below to change it.',
                            style: TextStyle(fontSize: 13, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LabeledField('Equipment name',
                hint: 'e.g. Tractor 50HP 4WD',
                icon: Icons.agriculture_outlined,
                controller: _name,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.required(v, 'Equipment name')),
            const SizedBox(height: 14),
            _dropdown(
              label: 'Type',
              icon: Icons.grid_view_outlined,
              value: draft.type,
              options: equipmentTypes,
              onChanged: notifier.setType,
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LabeledField('Price (RWF)',
                      hint: '25,000',
                      icon: Icons.payments_outlined,
                      controller: _price,
                      keyboard: TextInputType.number,
                      validator: Validators.price),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _dropdown(
                    label: 'Per',
                    icon: Icons.schedule,
                    value: draft.unit,
                    options: equipmentUnits,
                    display: _capital,
                    onChanged: notifier.setUnit,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _dropdown(
              label: 'District',
              icon: Icons.location_on_outlined,
              value: draft.district.isEmpty ? null : draft.district,
              options: districtOptions,
              validator: Validators.district,
              onChanged: notifier.setDistrict,
            ),
            const SizedBox(height: 14),
            LabeledField('Sector',
                hint: 'e.g. Mbazi',
                icon: Icons.place_outlined,
                controller: _sector,
                textInputAction: TextInputAction.next),
            const SizedBox(height: 14),
            LabeledField('Description',
                hint: 'Suitable for large farms...',
                icon: Icons.chat_bubble_outline,
                controller: _about,
                maxLines: 3),
            const SizedBox(height: 20),
            PrimaryButton(busy ? 'Saving…' : (editing ? 'Save Changes' : 'Save Equipment'),
                height: 54, onPressed: busy ? null : _save),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bookings
// ---------------------------------------------------------------------------

/// Requests / Upcoming / Completed bookings for the owner's machines.
class OwnerBookingsScreen extends ConsumerWidget {
  const OwnerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(_bookingFilterProvider);
    final all = ref.watch(_ownerBookingsProvider);
    final shown = switch (filter) {
      'Upcoming' => _withStatus(all, BookingStatus.confirmed),
      'Completed' => _withStatus(all, BookingStatus.completed),
      _ => _withStatus(all, BookingStatus.pending),
    };
    return Scaffold(
      appBar: const TopBar('Bookings', back: false),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          ChipRow(
            labels: const ['Requests', 'Upcoming', 'Completed'],
            selected: filter,
            onSelected: (v) => ref.read(_bookingFilterProvider.notifier).state = v,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                if (shown.isEmpty)
                  EmptyNote(filter == 'Requests' ? 'No pending requests.' : 'Nothing here yet.',
                      padding: 50),
                for (final b in shown) ...[
                  if (filter == 'Requests')
                    _RequestTile(booking: b)
                  else
                    _BookingRow(booking: b),
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

/// Confirmed or completed booking; confirmed ones can be marked complete.
class _BookingRow extends ConsumerWidget {
  const _BookingRow({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            AssetPhoto(booking.image, width: 60, height: 60, radius: 12),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.title,
                      style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700)),
                  Text('${booking.customerName} · ${booking.dateLabel} · ${booking.detail}',
                      style: const TextStyle(fontSize: 13.5, color: AppColors.muted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (booking.status == BookingStatus.confirmed)
              SoftButton('Complete',
                  onPressed: () => changeBookingStatus(
                      context, ref, booking, BookingStatus.completed, 'Booking completed.'))
            else
              StatusChip(booking.status),
          ],
        ),
      );
}

// ---------------------------------------------------------------------------
// Earnings
// ---------------------------------------------------------------------------

/// Net earnings, monthly chart and recent transactions from completed jobs.
class OwnerEarningsScreen extends ConsumerWidget {
  const OwnerEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(_ownerBookingsProvider);
    final earnings = EarningsView.from(bookings);
    final rows = payoutRows(bookings, Icons.agriculture_outlined);
    return Scaffold(
      appBar: const TopBar('Earnings', back: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BalanceCard(
            label: 'Total earnings',
            amount: rwf(earnings.net),
            note: 'After ${(BookingPricing.platformCommission * 100).round()}% platform commission',
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
          sectionTitle('Transactions'),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            const EmptyNote('Completed jobs will appear here.', padding: 24)
          else
            RowsCard(rows),
        ],
      ),
    );
  }
}
