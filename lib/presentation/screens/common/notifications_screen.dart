import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';

const _filters = ['All', 'Bookings', 'Payments', 'Training'];

/// Selected filter chip.
final _filterProvider = StateProvider.autoDispose<String>((ref) => 'All');

/// Ids swiped away but not yet removed by the live Firestore stream. A
/// dismissed `Dismissible` must leave the tree in the same frame, so the row
/// is hidden immediately and the delete runs in the background.
final _hiddenProvider = StateProvider.autoDispose<Set<String>>((ref) => const {});

/// Whether [n] belongs to the chip called [filter].
bool _matches(String filter, AppNotification n) => switch (filter) {
      'Bookings' => n.kind == 'booking' || n.kind == 'expert' || n.kind == 'dispute',
      'Payments' => n.kind == 'payment',
      'Training' => n.kind == 'training',
      _ => true,
    };

/// Icon and colours for a notification kind.
(IconData, Color, Color) _styleFor(String kind) => switch (kind) {
      'booking' => (Icons.check_circle_outline, AppColors.green100, AppColors.primaryDark),
      'payment' => (Icons.payments_outlined, AppColors.blueBg, AppColors.blue),
      'expert' => (Icons.groups_2_outlined, AppColors.purpleBg, AppColors.purple),
      'training' => (Icons.menu_book_outlined, AppColors.amberBg, AppColors.amberText),
      _ => (Icons.flag_outlined, AppColors.dangerBg, AppColors.danger),
    };

/// The user's notifications: tap to mark read, swipe left to delete.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(settingsControllerProvider.select((s) => s.notificationsEnabled));
    final filter = ref.watch(_filterProvider);
    final hidden = ref.watch(_hiddenProvider);
    final async = ref.watch(notificationsProvider);
    final controller = ref.read(notificationControllerProvider.notifier);

    Widget body;
    if (!enabled) {
      body = _Message(
        icon: Icons.notifications_off_outlined,
        text: 'Notifications are turned off.',
        action: 'Open settings',
        onAction: () => context.push('/settings'),
      );
    } else if (async.isLoading && !async.hasValue) {
      body = const Center(child: CircularProgressIndicator());
    } else if (async.hasError && !async.hasValue) {
      body = const _Message(
          icon: Icons.error_outline, text: 'Could not load notifications. Pull back later.');
    } else {
      final items = [
        for (final n in async.valueOrNull ?? const <AppNotification>[])
          if (_matches(filter, n) && !hidden.contains(n.id)) n
      ];
      body = ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          ChipRow(
            labels: _filters,
            selected: filter,
            onSelected: (v) => ref.read(_filterProvider.notifier).state = v,
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: Text("You're all caught up.", style: TextStyle(color: AppColors.muted)),
              ),
            ),
          for (final n in items)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Dismissible(
                key: ValueKey(n.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) async {
                  final hiddenIds = ref.read(_hiddenProvider.notifier);
                  hiddenIds.state = {...hiddenIds.state, n.id};
                  final result = await controller.delete(n);
                  if (!result.ok) {
                    hiddenIds.state = {...hiddenIds.state}..remove(n.id);
                  }
                  if (context.mounted) {
                    showToast(context, result.ok ? 'Notification deleted.' : result.error!);
                  }
                },
                child: _NotificationCard(
                  notification: n,
                  onTap: () => controller.markRead(n),
                ),
              ),
            ),
        ],
      );
    }

    return Scaffold(
      appBar: TopBar(
        'Notifications',
        actions: [
          if (enabled)
            TextButton(
              onPressed: () async {
                final result = await controller.markAllRead();
                if (context.mounted && !result.ok) showToast(context, result.error!);
              },
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              child: const Text('Mark all read',
                  style: TextStyle(fontSize: 13.5, color: AppColors.primaryDark)),
            ),
        ],
      ),
      body: body,
    );
  }
}

/// One notification row; unread ones are tinted and show a dot.
class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final style = _styleFor(n.kind);
    return AppCard(
      onTap: onTap,
      color: n.unread ? AppColors.green50 : Colors.white,
      borderColor: n.unread ? AppColors.green100 : AppColors.border,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(style.$1, bg: style.$2, fg: style.$3, size: 46, radius: 13),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (n.unread) ...[
                      Container(
                        width: 9,
                        height: 9,
                        decoration:
                            const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(n.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    Text(n.time, style: const TextStyle(fontSize: 13, color: AppColors.faint)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(n.body,
                    style: const TextStyle(fontSize: 14.5, height: 1.4, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Centered icon + text (+ optional button) for empty and error states.
class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action, this.onAction});

  final IconData icon;
  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: AppColors.faint),
              const SizedBox(height: 12),
              Text(text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: AppColors.muted)),
              if (action != null) ...[
                const SizedBox(height: 16),
                PrimaryButton(action!, expand: false, onPressed: onAction),
              ],
            ],
          ),
        ),
      );
}
