import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';

/// Shown to e-mail/password users until they confirm their address.
/// When the account becomes verified the router redirect moves them on.
class VerifyEmailScreen extends ConsumerWidget {
  const VerifyEmailScreen({super.key});

  Future<void> _run(BuildContext context, Future<ActionResult<void>> action, String okMessage) async {
    final result = await action;
    if (context.mounted) showToast(context, result.ok ? okMessage : result.error!);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(sessionProvider).valueOrNull?.email ?? '';
    final busy = ref.watch(authControllerProvider).busy;
    final auth = ref.read(authControllerProvider.notifier);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
          children: [
            const Center(child: IconTile(Icons.mark_email_unread_outlined, size: 84, radius: 26)),
            const SizedBox(height: 24),
            const Text('Verify your e-mail',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Text(
                'We sent a confirmation link to ${email.isEmpty ? 'your e-mail address' : email}. '
                'Open it, then come back and tap the button below.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, height: 1.45, color: AppColors.muted)),
            const SizedBox(height: 28),
            PrimaryButton(busy ? 'Checking…' : 'I have verified',
                height: 54,
                onPressed: busy
                    ? null
                    : () => _run(context, auth.refreshVerification(),
                        'Not verified yet. Open the link in your e-mail first.')),
            const SizedBox(height: 12),
            OutlineButtonX('Resend e-mail',
                height: 54,
                onPressed: busy
                    ? null
                    : () => _run(context, auth.resendVerification(), 'Verification e-mail sent.')),
            const SizedBox(height: 12),
            TextButton(
              onPressed: busy ? null : () => auth.signOut(),
              style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: const Text('Use another account',
                  style: TextStyle(fontSize: 15, color: AppColors.primaryDark)),
            ),
          ],
        ),
      ),
    );
  }
}
