import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/usecases/pricing.dart';
import '../../../domain/validators.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';
import 'calendar_card.dart';

const _starts = ['06:00', '08:00', '10:00', '12:00', '14:00'];

// Booking form state (kept in providers instead of widget State).
final _monthProvider = StateProvider.autoDispose<DateTime>((ref) => currentMonthStart());
final _dateProvider = StateProvider.autoDispose<DateTime>((ref) => tomorrow());
final _startProvider = StateProvider.autoDispose<String>((ref) => '08:00');

/// Selected duration option; null means "use the default for this unit".
final _durationProvider = StateProvider.autoDispose<String?>((ref) => null);

/// Pick a date, time and duration for a machine, then continue to payment.
class BookEquipmentScreen extends ConsumerStatefulWidget {
  const BookEquipmentScreen({super.key, required this.equipmentId});
  final String equipmentId;

  @override
  ConsumerState<BookEquipmentScreen> createState() => _BookEquipmentScreenState();
}

class _BookEquipmentScreenState extends ConsumerState<BookEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _location;
  final _notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill with the farmer's district; they can refine it.
    _location = TextEditingController(
        text: ref.read(profileProvider).valueOrNull?.district ?? '');
  }

  @override
  void dispose() {
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final e = ref.read(equipmentByIdProvider(widget.equipmentId));
    if (e == null || !_formKey.currentState!.validate()) return;
    final durations = BookingPricing.durationOptions(e.unit);
    final duration = ref.read(_durationProvider) ??
        durations[BookingPricing.defaultDurationIndex(e.unit)];
    final result = await ref.read(bookingControllerProvider.notifier).bookEquipment(
          equipment: e,
          date: ref.read(_dateProvider),
          startTime: ref.read(_startProvider),
          durationOption: duration,
          location: _location.text,
        );
    if (!mounted) return;
    if (!result.ok) {
      showToast(context, result.error!);
      return;
    }
    context.push('/farmer/pay/${result.value}');
  }

  @override
  Widget build(BuildContext context) {
    final e = ref.watch(equipmentByIdProvider(widget.equipmentId));
    if (e == null) {
      return const Scaffold(
          appBar: TopBar('Book Equipment'),
          body: Center(child: Text('This machine is no longer listed.')));
    }
    final month = ref.watch(_monthProvider);
    final date = ref.watch(_dateProvider);
    final start = ref.watch(_startProvider);
    final busy = ref.watch(bookingControllerProvider).busy;

    final durations = BookingPricing.durationOptions(e.unit);
    final duration = ref.watch(_durationProvider) ??
        durations[BookingPricing.defaultDurationIndex(e.unit)];
    final quote = BookingPricing.quote(
        price: e.price, quantity: BookingPricing.quantityOf(duration));

    return Scaffold(
      appBar: const TopBar('Book Equipment'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            AppCard(
              borderColor: AppColors.primary,
              padding: const EdgeInsets.all(12),
              onTap: () => context.go('/farmer/book'),
              child: Row(
                children: [
                  AssetPhoto(e.image, width: 84, height: 72, radius: 12),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        Text('${e.ownerName} · ${e.district}',
                            style: const TextStyle(fontSize: 13.5, color: AppColors.muted)),
                        const SizedBox(height: 4),
                        Text('${rwf(e.price)} / ${e.unit}',
                            style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Change',
                      style: TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('Service date',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            CalendarCard(
              month: month,
              selected: date,
              onMonthChanged: (m) => ref.read(_monthProvider.notifier).state = m,
              onSelected: (d) => ref.read(_dateProvider.notifier).state = d,
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _dropdown('Start time', Icons.schedule, start, _starts,
                      (v) => ref.read(_startProvider.notifier).state = v),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _dropdown(e.unit == 'hectare' ? 'Area' : 'Duration', Icons.timelapse,
                      duration, durations, (v) => ref.read(_durationProvider.notifier).state = v),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LabeledField('Farm location',
                hint: 'e.g. Huye · Mbazi',
                icon: Icons.location_on_outlined,
                controller: _location,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.required(v, 'Farm location')),
            const SizedBox(height: 16),
            LabeledField('Notes for the operator',
                hint: 'e.g. 2 ha maize field, ploughing',
                icon: Icons.chat_bubble_outline,
                controller: _notes),
            const SizedBox(height: 18),
            _Summary(
              lineLabel: '${e.type} · $duration × ${rwf(e.price).replaceFirst('RWF ', '')}',
              subtotal: quote.subtotal,
              fee: quote.fee,
              total: quote.total,
            ),
            const SizedBox(height: 18),
            PrimaryButton(busy ? 'Please wait…' : 'Continue to Payment',
                height: 54, onPressed: busy ? null : _submit),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(String label, IconData icon, String value, List<String> options,
      ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.body)),
        ),
        DropdownButtonFormField<String>(
          key: ValueKey('$label$value'),
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(prefixIcon: Icon(icon, color: AppColors.muted)),
          items: [for (final o in options) DropdownMenuItem(value: o, child: Text(o))],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}

/// Price breakdown card shared by the booking screens.
class _Summary extends StatelessWidget {
  const _Summary(
      {required this.lineLabel,
      required this.subtotal,
      required this.fee,
      required this.total});
  final String lineLabel;
  final int subtotal, fee, total;

  Widget _row(String l, String r) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(l, style: const TextStyle(fontSize: 14.5, color: AppColors.body))),
          const SizedBox(width: 8),
          Text(r, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
        ],
      );

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration:
            BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(18)),
        child: Column(
          children: [
            _row(lineLabel, rwf(subtotal)),
            const SizedBox(height: 10),
            _row('Service fee', rwf(fee)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                Text(rwf(total),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
              ],
            ),
          ],
        ),
      );
}
