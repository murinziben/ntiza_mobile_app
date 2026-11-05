import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/validators.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';

/// True once the reset e-mail has been requested.
final _sentProvider = StateProvider.autoDispose<bool>((ref) => false);

/// Sends a Firebase password-reset e-mail.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final result = await ref.read(authControllerProvider.notifier).sendPasswordReset(_email.text);
    if (!mounted) return;
    if (result.ok) {
      ref.read(_sentProvider.notifier).state = true;
    } else {
      showToast(context, result.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(authControllerProvider).busy;
    final sent = ref.watch(_sentProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const TopBar('Reset Password'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          children: [
            const Text('Forgot your password?',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text(
                'Enter the e-mail you signed up with and we will send you a link to choose a new password.',
                style: TextStyle(fontSize: 16, height: 1.4, color: AppColors.muted)),
            const SizedBox(height: 24),
            LabeledField('E-mail',
                hint: 'you@example.com',
                icon: Icons.mail_outline,
                controller: _email,
                keyboard: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
                onSubmitted: (_) => busy ? null : _send()),
            if (sent) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.green50, borderRadius: BorderRadius.circular(14)),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.mark_email_read_outlined, color: AppColors.primaryDark),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                          'Reset link sent. Check your inbox (and spam folder), then log in with your new password.',
                          style: TextStyle(fontSize: 14.5, height: 1.4, color: AppColors.body)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),
            PrimaryButton(busy ? 'Sending…' : (sent ? 'Send again' : 'Send reset link'),
                height: 54, onPressed: busy ? null : _send),
          ],
        ),
      ),
    );
  }
}
