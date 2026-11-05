import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';

/// Explains why an account cannot be used yet (pending, rejected, suspended).
/// The profile stream is live, so approval moves the user on automatically.
class AccountStatusScreen extends ConsumerWidget {
  const AccountStatusScreen({super.key});

  /// Icon, heading and explanation for each non-active status.
  (IconData, String, String) _copy(AppUser? me) => switch (me?.status) {
        UserStatus.rejected => (
            Icons.block,
            'Application not approved',
            'Sorry, your partner application was not approved. Contact support if you think this is a mistake.'
          ),
        UserStatus.suspended => (
            Icons.pause_circle_outline,
            'Account suspended',
            'Your account has been suspended. Please contact support to restore access.'
          ),
        _ => (
            Icons.hourglass_top,
            'Application under review',
            'Your application is under review. We will notify you as soon as the NTIZA team approves it — this page updates by itself.'
          ),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(profileProvider).valueOrNull;
    final copy = _copy(me);
    final busy = ref.watch(authControllerProvider).busy;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
          children: [
            Center(child: IconTile(copy.$1, size: 84, radius: 26)),
            const SizedBox(height: 24),
            Text(copy.$2,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Text(copy.$3,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, height: 1.45, color: AppColors.muted)),
            const SizedBox(height: 28),
            OutlineButtonX('Log out',
                height: 54,
                color: AppColors.danger,
                onPressed: busy ? null : () => ref.read(authControllerProvider.notifier).signOut()),
          ],
        ),
      ),
    );
  }
}
