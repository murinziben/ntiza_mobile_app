import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/entities.dart';
import '../../widgets/ui.dart';
import '../../providers/providers.dart';
import '../public/public_shell.dart';

/// Bottom-nav shell shared by every role.
class RoleShell extends StatelessWidget {
  const RoleShell({super.key, required this.shell, required this.items});
  final StatefulNavigationShell shell;
  final List<NavItem> items;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: shell,
        bottomNavigationBar: NtizaBottomNav(
          items: items,
          index: shell.currentIndex,
          onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        ),
      );
}

/// Greeting header used on role dashboards.
class RoleHeader extends ConsumerWidget {
  const RoleHeader(
      {super.key, this.initials, this.title, this.subtitle, this.icon, this.search = false});
  final String? initials, title, subtitle;
  final IconData? icon;
  final bool search;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(profileProvider).valueOrNull;
    final initials = this.initials ?? initialsOf(me?.name ?? 'N');
    final title = this.title ?? 'Muraho, ${me?.firstName ?? ''} 👋';
    final subtitle = this.subtitle ?? '${me?.role.label ?? ''} · ${me?.district ?? ''}';
    return Row(
        children: [
          if (icon != null)
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                  color: AppColors.ink, borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: Colors.white),
            )
          else
            InitialsAvatar(initials, size: 54, bg: AppColors.primary, fg: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                Text(subtitle, style: const TextStyle(fontSize: 14, color: AppColors.muted)),
              ],
            ),
          ),
          // The bell opens the notification list (it shows an unread dot).
          // `search` is kept for source compatibility and no longer changes it.
          InkResponse(
            onTap: () => context.push('/notifications'),
            radius: 28,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(child: BellIcon()),
            ),
          ),
        ],
      );
  }
}

class StatSpec {
  const StatSpec(this.value, this.label, this.icon, this.bg, this.fg);
  final String value, label;
  final IconData icon;
  final Color bg, fg;
}

/// 2×2 grid of stat cards.
class StatGrid extends StatelessWidget {
  const StatGrid(this.stats, {super.key});
  final List<StatSpec> stats;

  Widget _card(StatSpec s) => AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconTile(s.icon, bg: s.bg, fg: s.fg, size: 44, radius: 13),
            const SizedBox(height: 14),
            Text(s.value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(s.label, style: const TextStyle(fontSize: 14.5, color: AppColors.muted)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Column(
        children: [
          for (var i = 0; i < stats.length; i += 2) ...[
            if (i > 0) const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _card(stats[i])),
                const SizedBox(width: 14),
                Expanded(
                    child: i + 1 < stats.length ? _card(stats[i + 1]) : const SizedBox()),
              ],
            ),
          ],
        ],
      );
}

/// Bar chart card (last bar highlighted).
class BarCard extends StatelessWidget {
  const BarCard(
      {super.key,
      required this.caption,
      required this.total,
      required this.labels,
      required this.values,
      this.delta,
      this.height = 120});
  final String caption, total;
  final String? delta;
  final List<String> labels;
  final List<double> values;
  final double height;

  @override
  Widget build(BuildContext context) {
    final peak = values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);
    // Avoid dividing by zero when every value is 0.
    final maxV = peak <= 0 ? 1.0 : peak;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(caption, style: const TextStyle(fontSize: 14, color: AppColors.muted)),
              if (delta != null) Pill(delta!, big: true),
            ],
          ),
          const SizedBox(height: 2),
          Text(total, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          SizedBox(
            height: height + 22,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < values.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: height * values[i] / maxV,
                            decoration: BoxDecoration(
                              color: i == values.length - 1
                                  ? AppColors.primary
                                  : AppColors.green100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(labels[i],
                              style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Green balance card with a white action button.
class BalanceCard extends StatelessWidget {
  const BalanceCard(
      {super.key,
      required this.label,
      required this.amount,
      required this.note,
      required this.button,
      this.onTap});
  final String label, amount, note, button;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: AppColors.primaryDark, borderRadius: BorderRadius.circular(22)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14.5)),
            const SizedBox(height: 4),
            Text(amount,
                style: const TextStyle(
                    color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(note, style: const TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 14),
            OutlineButtonX(button, expand: false, height: 46, onPressed: onTap),
          ],
        ),
      );
}

/// Card with a photo/avatar, details, price and Decline / Accept buttons.
class RequestCard extends StatelessWidget {
  const RequestCard(
      {super.key,
      this.image,
      this.initials,
      required this.title,
      required this.lines,
      this.price,
      this.tag,
      this.tags = const [],
      required this.declineLabel,
      required this.acceptLabel,
      this.onDecline,
      this.onAccept});
  final String? image, initials;
  final String title;
  final List<String> lines;
  final String? price;
  final String? tag;
  final List<Widget> tags;
  final String declineLabel, acceptLabel;
  final VoidCallback? onDecline, onAccept;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (image != null)
                  AssetPhoto(image!, width: 62, height: 62, radius: 12)
                else
                  InitialsAvatar(initials ?? '?', size: 62),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(fontSize: 17.5, fontWeight: FontWeight.w700)),
                      for (final l in lines)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(l,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                      tag == l ? FontWeight.w600 : FontWeight.w400,
                                  color: tag == l
                                      ? AppColors.primaryDark
                                      : AppColors.muted)),
                        ),
                    ],
                  ),
                ),
                if (price != null) ...[
                  const SizedBox(width: 8),
                  Text(price!,
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark)),
                ],
              ],
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: tags),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: OutlineButtonX(declineLabel, height: 46, onPressed: onDecline)),
                const SizedBox(width: 12),
                Expanded(child: PrimaryButton(acceptLabel, height: 46, onPressed: onAccept)),
              ],
            ),
          ],
        ),
      );
}

/// Person row: avatar, name, coloured sub line, meta, trailing soft button.
class PersonCard extends StatelessWidget {
  const PersonCard(
      {super.key,
      required this.initials,
      required this.name,
      this.accent,
      this.meta,
      this.star = true,
      this.tags = const [],
      this.action,
      this.onAction});
  final String initials, name;
  final String? accent, meta, action;
  final bool star;
  final List<Widget> tags;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InitialsAvatar(initials, size: 60),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(fontSize: 17.5, fontWeight: FontWeight.w700)),
                      if (accent != null)
                        Text(accent!,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark)),
                      if (meta != null)
                        Row(
                          children: [
                            if (star) ...[
                              const Icon(Icons.star, size: 15, color: AppColors.amber),
                              const SizedBox(width: 4),
                            ],
                            Flexible(
                              child: Text(meta!,
                                  style: const TextStyle(fontSize: 13.5, color: AppColors.muted)),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(width: 8),
                  SoftButton(action!, onPressed: onAction),
                ],
              ],
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: tags),
            ],
          ],
        ),
      );
}

/// Card containing divided rows (transactions, payouts, settings).
class RowsCard extends StatelessWidget {
  const RowsCard(this.rows, {super.key});
  final List<RowSpec> rows;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          children: [
            for (final r in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    IconTile(r.icon, bg: r.bg, fg: r.fg, size: 46, radius: 13),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          Text(r.sub,
                              style: const TextStyle(fontSize: 13.5, color: AppColors.muted)),
                        ],
                      ),
                    ),
                    Text(r.amount,
                        style: TextStyle(
                            fontSize: 16.5, fontWeight: FontWeight.w700, color: r.amountColor)),
                  ],
                ),
              ),
          ],
        ),
      );
}

class RowSpec {
  const RowSpec(this.icon, this.title, this.sub, this.amount,
      {this.bg = AppColors.green100,
      this.fg = AppColors.primaryDark,
      this.amountColor = AppColors.primaryDark});
  final IconData icon;
  final String title, sub, amount;
  final Color bg, fg, amountColor;
}

/// Generic profile screen for non-farmer roles.
class RoleProfileScreen extends ConsumerWidget {
  const RoleProfileScreen({super.key});

  void _showHelp(BuildContext context) => showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Help & support'),
          content: const Text(
              'Need a hand? E-mail support@ntiza.app and the NTIZA team will reply within one working day.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(profileProvider).valueOrNull;
    final initials = initialsOf(me?.name ?? 'N');
    final name = me?.name ?? '';
    final subtitle = '${me?.role.label ?? ''} · ${me?.district ?? ''}';
    final busy = ref.watch(authControllerProvider).busy;
    final rows = <(IconData, String, VoidCallback)>[
      (Icons.person_outline, 'Personal information', () => context.push('/profile/edit')),
      (Icons.settings_outlined, 'Settings', () => context.push('/settings')),
      (Icons.help_outline, 'Help & support', () => _showHelp(context)),
    ];
    return Scaffold(
      appBar: const TopBar('Profile', back: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Center(
              child: InitialsAvatar(initials, size: 84, bg: AppColors.primary, fg: Colors.white)),
          const SizedBox(height: 12),
          Center(
              child: Text(name,
                  style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800))),
          const SizedBox(height: 4),
          Center(
              child: Text(subtitle,
                  style: const TextStyle(fontSize: 14, color: AppColors.muted))),
          const SizedBox(height: 22),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final r in rows)
                  InkWell(
                    onTap: r.$3,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 56),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // The router redirect returns the user to the public area after sign-out.
          OutlineButtonX('Log out',
              color: AppColors.danger,
              onPressed: busy ? null : () => ref.read(authControllerProvider.notifier).signOut()),
        ],
      ),
    );
  }
}

/// Section title row used inside role screens.
Widget sectionTitle(String t, {String? action, VoidCallback? onAction}) =>
    SectionHeader(t, action: action, onAction: onAction);

/// Neutral tag chip ("Phone call", "Video call" …).
Widget tagChip(String label) =>
    Pill(label, big: true, bg: AppColors.neutral, fg: AppColors.body);
