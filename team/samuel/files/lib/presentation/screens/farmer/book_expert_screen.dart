import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/validators.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';
import 'calendar_card.dart';

const _times = ['08:00', '09:00', '10:00', '11:00', '14:00', '15:00', '16:00'];
const _modes = ['Phone call', 'Video call', 'Farm visit'];

// Form state kept in providers instead of widget State.
final _monthProvider = StateProvider.autoDispose<DateTime>((ref) => currentMonthStart());
final _dateProvider = StateProvider.autoDispose<DateTime>((ref) => tomorrow());
final _timeProvider = StateProvider.autoDispose<String>((ref) => '10:00');
final _modeProvider = StateProvider.autoDispose<String>((ref) => 'Phone call');

/// Book a paid consultation with an expert, then continue to payment.
class BookExpertScreen extends ConsumerStatefulWidget {
  const BookExpertScreen({super.key, required this.expertId});
  final String expertId;

  @override
  ConsumerState<BookExpertScreen> createState() => _BookExpertScreenState();
}

class _BookExpertScreenState extends ConsumerState<BookExpertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topic = TextEditingController();

  @override
  void dispose() {
    _topic.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final expert = ref.read(expertByIdProvider(widget.expertId));
    if (expert == null || !_formKey.currentState!.validate()) return;
    final result = await ref.read(bookingControllerProvider.notifier).bookExpert(
          expert: expert,
          date: ref.read(_dateProvider),
          time: ref.read(_timeProvider),
          mode: ref.read(_modeProvider),
          topic: _topic.text,
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
    final expert = ref.watch(expertByIdProvider(widget.expertId));
    if (expert == null) {
      return const Scaffold(
          appBar: TopBar('Book Expert'),
          body: Center(child: Text('This expert is no longer listed.')));
    }
    final month = ref.watch(_monthProvider);
    final date = ref.watch(_dateProvider);
    final time = ref.watch(_timeProvider);
    final mode = ref.watch(_modeProvider);
    final busy = ref.watch(bookingControllerProvider).busy;
    final schedule = expert.fullSchedule;
    // An expert with no working days set accepts any day.
    final hasSchedule = schedule.values.any((h) => h.isNotEmpty);
    // DateTime.weekday is 1 (Monday) to 7 (Sunday); fullSchedule keys are in that order.
    final dayNames = schedule.keys.toList();

    return Scaffold(
      appBar: const TopBar('Book Expert'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            AppCard(
              borderColor: AppColors.primary,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  InitialsAvatar(initialsOf(expert.name), size: 58),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(expert.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        Text(expert.field,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark)),
                        RatingLine(expert.rating, '${expert.years} years experience'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!expert.accepting) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.dangerBg, borderRadius: BorderRadius.circular(14)),
                child: const Text('This expert is not taking new consultations right now.',
                    style: TextStyle(color: AppColors.danger, fontSize: 14)),
              ),
            ],
            const SizedBox(height: 22),
            const Text('Consultation date',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            CalendarCard(
              month: month,
              selected: date,
              isEnabled: (d) => !hasSchedule || schedule[dayNames[d.weekday - 1]]!.isNotEmpty,
              onMonthChanged: (m) => ref.read(_monthProvider.notifier).state = m,
              onSelected: (d) => ref.read(_dateProvider.notifier).state = d,
            ),
            const SizedBox(height: 18),
            const Text('Time', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ChipRow(
              padding: EdgeInsets.zero,
              labels: _times,
              selected: time,
              onSelected: (v) => ref.read(_timeProvider.notifier).state = v,
            ),
            const SizedBox(height: 18),
            const Text('How would you like to meet?',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ChipRow(
              padding: EdgeInsets.zero,
              labels: _modes,
              selected: mode,
              onSelected: (v) => ref.read(_modeProvider.notifier).state = v,
            ),
            const SizedBox(height: 18),
            LabeledField('What do you need help with?',
                hint: 'e.g. Maize leaves turning yellow',
                icon: Icons.chat_bubble_outline,
                controller: _topic,
                maxLines: 3,
                validator: (v) => Validators.required(v, 'Topic')),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColors.green50, borderRadius: BorderRadius.circular(18)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('Total · ${expert.sessionMinutes} min session',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 8),
                  Text(rwf(expert.fee),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(busy ? 'Please wait…' : 'Continue to Payment',
                height: 54, onPressed: (busy || !expert.accepting) ? null : _submit),
          ],
        ),
      ),
    );
  }
}
