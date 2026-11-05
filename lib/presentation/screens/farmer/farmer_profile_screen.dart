import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';

/// Farmer profile with links to edit details, settings and notifications.
class FarmerProfileScreen extends ConsumerWidget {
  const FarmerProfileScreen({super.key});

  Future<void> _showHelp(BuildContext context) => showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Help & support'),
          content: const Text(
              'Open a booking and tap "Report a problem" and an admin will review it. '
              'For anything else, contact the NTIZA team through your district agent.'),
          actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))],
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(profileProvider).valueOrNull;
    final busy = ref.watch(authControllerProvider).busy;
    final rows = <(IconData, String, VoidCallback)>[
      (Icons.person_outline, 'Personal information', () => context.push('/profile/edit')),
      (Icons.settings_outlined, 'Settings', () => context.push('/settings')),
      (Icons.notifications_none, 'Notifications', () => context.push('/notifications')),
      (Icons.help_outline, 'Help & support', () => _showHelp(context)),
    ];

    return Scaffold(
      appBar: const TopBar('Profile', back: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Center(
              child: InitialsAvatar(initialsOf(me?.name ?? 'N'),
                  size: 84, bg: AppColors.primary, fg: Colors.white)),
          const SizedBox(height: 12),
          Center(
            child: Text(me?.name ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text('Farmer · ${me?.district ?? ''} · ${me?.phone ?? ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.muted)),
          ),
          const SizedBox(height: 22),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final r in rows)
                  InkWell(
                    onTap: r.$3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          IconTile(r.$1, bg: AppColors.green50, size: 40, radius: 12),
                          const SizedBox(width: 14),
                          Expanded(
                              child: Text(r.$2,
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w600))),
                          const Icon(Icons.chevron_right, color: AppColors.faint),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlineButtonX(busy ? 'Logging out…' : 'Log out', color: AppColors.danger,
              onPressed: busy
                  ? null
                  : () async {
                      final r = await ref.read(authControllerProvider.notifier).signOut();
                      if (!context.mounted) return;
                      if (r.ok) {
                        context.go('/home');
                      } else {
                        showToast(context, r.error!);
                      }
                    }),
        ],
      ),
    );
  }
}
