import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/constants.dart';
import '../../../domain/validators.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';

// Payment form state lives in providers, not widget State.
final _methodProvider = StateProvider.autoDispose<String>((ref) => mobileMoneyProviders.first);
final _waitingProvider = StateProvider.autoDispose<bool>((ref) => false);

/// Mobile Money checkout. The approval step is simulated (see the demo note).
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.bookingRef});
  final String bookingRef;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    _phone = TextEditingController(text: ref.read(profileProvider).valueOrNull?.phone ?? '');
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final booking = ref.read(bookingByRefProvider(widget.bookingRef));
    if (booking == null || !_formKey.currentState!.validate()) return;
    final via = ref.read(_methodProvider);
    ref.read(_waitingProvider.notifier).state = true;
    // Simulated approval prompt; a real provider callback replaces this later.
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final result = await ref.read(bookingControllerProvider.notifier).pay(booking, via);
    if (!mounted) return;
    ref.read(_waitingProvider.notifier).state = false;
    if (!result.ok) {
      showToast(context, result.error!);
      return;
    }
    context.go('/farmer/booking/${widget.bookingRef}');
  }

  @override
  Widget build(BuildContext context) {
    final b = ref.watch(bookingByRefProvider(widget.bookingRef));
    if (b == null) {
      return const Scaffold(
          appBar: TopBar('Payment'), body: Center(child: CircularProgressIndicator()));
    }
    final method = ref.watch(_methodProvider);
    final waiting = ref.watch(_waitingProvider);

    return Scaffold(
      appBar: const TopBar('Payment'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
              decoration: BoxDecoration(
                  color: AppColors.primaryDark, borderRadius: BorderRadius.circular(22)),
              child: Column(
                children: [
                  const Text('Amount to pay',
                      style: TextStyle(color: Colors.white, fontSize: 14.5)),
                  const SizedBox(height: 6),
                  Text(rwf(b.total),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text('Booking #${b.ref} · ${b.title}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('Choose payment method',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            for (final name in mobileMoneyProviders) ...[
              _Method(
                selected: method == name,
                title: name == 'MTN MoMo' ? 'MTN Mobile Money' : name,
                sub: name == 'MTN MoMo' ? 'Pay with MoMo · 078 / 079' : 'Pay with Airtel · 072 / 073',
                logo: name == 'MTN MoMo' ? const _MtnLogo() : const _AirtelLogo(),
                onTap: () => ref.read(_methodProvider.notifier).state = name,
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 6),
            LabeledField('Mobile Money number',
                hint: '078 812 3456',
                icon: Icons.smartphone_outlined,
                controller: _phone,
                keyboard: TextInputType.phone,
                validator: Validators.phone),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.blueBg, borderRadius: BorderRadius.circular(14)),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, color: AppColors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                        "You'll get a prompt on your phone. Enter your MoMo PIN to approve — NTIZA never asks for your PIN.",
                        style: TextStyle(color: AppColors.blue, fontSize: 14, height: 1.4)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (b.isPaid)
              PrimaryButton('Already paid · View booking',
                  height: 54, onPressed: () => context.go('/farmer/booking/${b.ref}'))
            else
              PrimaryButton(waiting ? 'Waiting for approval…' : 'Pay ${rwf(b.total)}',
                  height: 54, onPressed: waiting ? null : _pay),
            if (waiting) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.amberBg, borderRadius: BorderRadius.circular(14)),
                child: const Row(
                  children: [
                    Icon(Icons.schedule, color: AppColors.amberText),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Waiting for approval…',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          Text('Approve the prompt on your phone.',
                              style: TextStyle(fontSize: 14, color: AppColors.body)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
                'Demo payment: the approval is simulated and no money is moved. '
                'Live Mobile Money needs a payments backend.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: AppColors.muted, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

class _MtnLogo extends StatelessWidget {
  const _MtnLogo();

  @override
  Widget build(BuildContext context) => Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: const Color(0xFFFFCC00), borderRadius: BorderRadius.circular(14)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.6),
              borderRadius: BorderRadius.circular(99)),
          child: const Text('MTN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        ),
      );
}

class _AirtelLogo extends StatelessWidget {
  const _AirtelLogo();

  @override
  Widget build(BuildContext context) => Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14)),
        child: const Text('airtel',
            style: TextStyle(color: Color(0xFFE40000), fontWeight: FontWeight.w800, fontSize: 14)),
      );
}

/// One selectable payment provider row.
class _Method extends StatelessWidget {
  const _Method(
      {required this.selected,
      required this.title,
      required this.sub,
      required this.logo,
      required this.onTap});
  final bool selected;
  final String title, sub;
  final Widget logo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: onTap,
        color: selected ? AppColors.green50 : Colors.white,
        borderColor: selected ? AppColors.primary : AppColors.border,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            logo,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  Text(sub, style: const TextStyle(fontSize: 13.5, color: AppColors.muted)),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.white,
                border: Border.all(
                    color: selected ? AppColors.primary : AppColors.faint, width: 1.6),
              ),
              child: selected ? const Icon(Icons.circle, size: 10, color: Colors.white) : null,
            ),
          ],
        ),
      );
}
