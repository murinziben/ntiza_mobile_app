import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/usecases/pricing.dart';
import '../../../domain/validators.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';
import '../common/role_widgets.dart';
import '../public/public_shell.dart';

const adminNav = [
  NavItem('Overview', Icons.grid_view_outlined),
  NavItem('Applications', Icons.description_outlined),
  NavItem('Users', Icons.groups_2_outlined),
  NavItem('Disputes', Icons.flag_outlined),
  NavItem('More', Icons.menu),
];

// ---- shared helpers ----------------------------------------------------------

/// Asks the user to confirm an action before it runs.
Future<bool> _confirm(BuildContext context, String title, String message, String action,
    {bool destructive = true}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(48, 48),
            foregroundColor: destructive ? AppColors.danger : AppColors.primaryDark,
          ),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(action),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Compact text button with an icon, at least 48dp tall.
Widget _miniAction(String label, IconData icon, VoidCallback? onTap,
        {Color color = AppColors.primaryDark}) =>
    TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(minimumSize: const Size(48, 48), foregroundColor: color),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );

/// Centered grey message for empty lists.
class _Empty extends StatelessWidget {
  const _Empty(this.text, {this.padding = 50});
  final String text;
  final double padding;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: padding),
        child: Center(
          child: Text(text,
              textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
        ),
      );
}

// ---- overview ------------------------------------------------------------------

/// Platform summary: users, applications, bookings, disputes and revenue.
class AdminOverview extends ConsumerWidget {
  const AdminOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(allUsersProvider).valueOrNull ?? const <AppUser>[];
    final bookings = ref.watch(allBookingsProvider).valueOrNull ?? const <Booking>[];
    final disputes = ref.watch(disputesProvider).valueOrNull ?? const <Dispute>[];
    final pendingApps = users.where((u) => u.status == UserStatus.pending).toList();
    final openDisputes = disputes.where((d) => d.isOpen).length;

    // Platform revenue = the commission kept on every completed booking.
    int commission(Booking b) => (b.total * BookingPricing.platformCommission).round();
    final series = BookingStats.monthly(bookings, commission, now: DateTime.now());

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            RoleHeader(
                initials: 'AD',
                icon: Icons.shield_outlined,
                title: 'Admin Console',
                subtitle: 'NTIZA platform · Today, ${dayMonth(DateTime.now())}'),
            const SizedBox(height: 16),
            StatGrid([
              StatSpec('${users.length}', 'Total Users', Icons.groups_2_outlined,
                  AppColors.green100, AppColors.primaryDark),
              StatSpec('${pendingApps.length}', 'Pending Applications',
                  Icons.description_outlined, AppColors.amberBg, AppColors.amberText),
              StatSpec('${bookings.length}', 'Total Bookings', Icons.calendar_today_outlined,
                  AppColors.blueBg, AppColors.blue),
              StatSpec('$openDisputes', 'Open Disputes', Icons.flag_outlined,
                  AppColors.purpleBg, AppColors.purple),
            ]),
            const SizedBox(height: 16),
            BarCard(
              caption: 'Commission revenue · 6 months',
              total: rwf(series.fold<int>(0, (s, m) => s + m.amount)),
              labels: [for (final m in series) m.label],
              values: BookingStats.chartValues(series),
            ),
            const SizedBox(height: 24),
            sectionTitle('Pending Applications',
                action: 'Review', onAction: () => context.go('/admin/applications')),
            const SizedBox(height: 12),
            if (pendingApps.isEmpty) const _Empty('No pending applications.', padding: 16),
            for (final a in pendingApps.take(2)) ...[
              PersonCard(
                initials: initialsOf(a.name),
                name: a.name,
                accent: '${a.role.label} · ${a.district}',
                meta: a.createdAt == null
                    ? 'Applied recently'
                    : 'Applied ${timeAgo(a.createdAt!)}',
                action: 'Review',
                onAction: () => context.go('/admin/applications'),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            sectionTitle('Recent Bookings'),
            const SizedBox(height: 12),
            if (bookings.isEmpty) const _Empty('No bookings yet.', padding: 16),
            for (final b in bookings.take(3)) ...[
              _BookingTile(booking: b),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

/// One booking in the admin's recent list.
class _BookingTile extends StatelessWidget {
  const _BookingTile({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            AssetPhoto(booking.image, width: 60, height: 60, radius: 12),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${booking.title} · ${booking.customerName}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('${booking.ref} · ${rwf(booking.total)}',
                      style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusChip(booking.status),
          ],
        ),
      );
}

// ---- applications --------------------------------------------------------------

final _applicationFilterProvider = StateProvider.autoDispose<String>((ref) => 'Pending');

/// Approve or reject owners, experts and agents who applied to join.
class AdminApplicationsScreen extends ConsumerWidget {
  const AdminApplicationsScreen({super.key});

  Future<void> _decide(BuildContext context, WidgetRef ref, AppUser a,
      {required bool approve}) async {
    final result = await ref
        .read(adminControllerProvider.notifier)
        .decideApplication(a, approve: approve);
    if (!context.mounted) return;
    showToast(context,
        result.ok ? (approve ? '${a.name} approved.' : '${a.name} rejected.') : result.error!);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(_applicationFilterProvider);
    final busy = ref.watch(adminControllerProvider).busy;
    final partners = [
      for (final u in ref.watch(allUsersProvider).valueOrNull ?? const <AppUser>[])
        if (u.role.needsApproval) u,
    ];
    final wanted = switch (filter) {
      'Approved' => UserStatus.active,
      'Rejected' => UserStatus.rejected,
      _ => UserStatus.pending,
    };
    final list = partners.where((u) => u.status == wanted).toList();
    final pendingCount = partners.where((u) => u.status == UserStatus.pending).length;

    return Scaffold(
      appBar: const TopBar('Applications', back: false),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          ChipRow(
            labels: const ['Pending', 'Approved', 'Rejected'],
            selected: filter,
            onSelected: (v) => ref.read(_applicationFilterProvider.notifier).state = v,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text('$pendingCount pending',
                style: const TextStyle(fontSize: 13.5, color: AppColors.muted)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                if (list.isEmpty) const _Empty('Nothing here.', padding: 60),
                for (final a in list) ...[
                  AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            InitialsAvatar(initialsOf(a.name), size: 60),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.name,
                                      style: const TextStyle(
                                          fontSize: 17.5, fontWeight: FontWeight.w700)),
                                  Text('${a.role.label} · ${a.district}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryDark)),
                                  Text(a.phone,
                                      style: const TextStyle(
                                          fontSize: 13.5, color: AppColors.muted)),
                                  if (a.email.isNotEmpty)
                                    Text(a.email,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 13.5, color: AppColors.muted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (filter == 'Pending') ...[
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                  child: OutlineButtonX('Reject',
                                      height: 48,
                                      onPressed:
                                          busy ? null : () => _decide(context, ref, a, approve: false))),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: PrimaryButton('Approve',
                                      height: 48,
                                      onPressed:
                                          busy ? null : () => _decide(context, ref, a, approve: true))),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---- users ---------------------------------------------------------------------

final _userQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final _userRoleFilterProvider = StateProvider.autoDispose<String>((ref) => 'All');

/// All accounts, with suspend / reactivate / delete for non-admin users.
class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  bool _matches(AppUser u, String filter) => switch (filter) {
        'Farmers' => u.role == Role.farmer,
        'Owners' => u.role == Role.owner,
        'Experts' => u.role == Role.expert,
        'Agents' => u.role == Role.agent,
        _ => true,
      };

  Future<void> _toggleSuspend(BuildContext context, WidgetRef ref, AppUser u) async {
    final suspended = u.status == UserStatus.suspended;
    final result = await ref
        .read(adminControllerProvider.notifier)
        .setUserStatus(u, suspended ? UserStatus.active : UserStatus.suspended);
    if (!context.mounted) return;
    showToast(
        context,
        result.ok
            ? (suspended ? '${u.name} reactivated.' : '${u.name} suspended.')
            : result.error!);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, AppUser u) async {
    final ok = await _confirm(context, 'Delete user?',
        '${u.name}\'s profile will be removed. This cannot be undone.', 'Delete');
    if (!ok || !context.mounted) return;
    final result = await ref.read(adminControllerProvider.notifier).deleteUser(u);
    if (!context.mounted) return;
    showToast(context, result.ok ? 'User deleted.' : result.error!);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(allUsersProvider).valueOrNull ?? const <AppUser>[];
    final me = ref.watch(currentUidProvider);
    final filter = ref.watch(_userRoleFilterProvider);
    final q = ref.watch(_userQueryProvider).trim().toLowerCase();
    final items = all
        .where((u) => _matches(u, filter) && (q.isEmpty || u.name.toLowerCase().contains(q)))
        .toList();

    return Scaffold(
      appBar: const TopBar('Users', back: false),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SearchField(
                hint: 'Search users',
                onChanged: (v) => ref.read(_userQueryProvider.notifier).state = v),
          ),
          const SizedBox(height: 14),
          ChipRow(
            labels: const ['All', 'Farmers', 'Owners', 'Experts', 'Agents'],
            selected: filter,
            onSelected: (v) => ref.read(_userRoleFilterProvider.notifier).state = v,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                if (items.isEmpty) const _Empty('No users found.'),
                for (final u in items) ...[
                  // Admins (including yourself) cannot be managed from here.
                  PersonCard(
                    initials: initialsOf(u.name),
                    name: u.name,
                    accent: u.role.label,
                    meta: u.district.isEmpty ? u.email : '${u.district} · ${u.email}',
                    star: false,
                    tags: [
                      StatusChip(u.status),
                      if (u.role != Role.admin && u.uid != me) ...[
                        _miniAction(
                          u.status == UserStatus.suspended ? 'Reactivate' : 'Suspend',
                          u.status == UserStatus.suspended
                              ? Icons.check_circle_outline
                              : Icons.block,
                          () => _toggleSuspend(context, ref, u),
                          color: u.status == UserStatus.suspended
                              ? AppColors.primaryDark
                              : AppColors.danger,
                        ),
                        _miniAction('Delete', Icons.delete_outline, () => _delete(context, ref, u),
                            color: AppColors.danger),
                      ],
                    ],
                  ),
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

// ---- disputes ------------------------------------------------------------------

final _disputeFilterProvider = StateProvider.autoDispose<String>((ref) => 'Open');

/// Problems reported on bookings, with resolve and delete.
class AdminDisputesScreen extends ConsumerWidget {
  const AdminDisputesScreen({super.key});

  Future<void> _resolve(BuildContext context, WidgetRef ref, Dispute d) async {
    final note = await showDialog<String>(
      context: context,
      builder: (_) => _ResolveDialog(dispute: d),
    );
    if (note == null || !context.mounted) return;
    final result = await ref.read(adminControllerProvider.notifier).resolveDispute(d.id, note);
    if (!context.mounted) return;
    showToast(context, result.ok ? 'Dispute resolved.' : result.error!);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Dispute d) async {
    final ok = await _confirm(context, 'Delete dispute?',
        'The record for ${d.bookingRef} will be removed.', 'Delete');
    if (!ok || !context.mounted) return;
    final result = await ref.read(adminControllerProvider.notifier).deleteDispute(d.id);
    if (!context.mounted) return;
    showToast(context, result.ok ? 'Dispute deleted.' : result.error!);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(_disputeFilterProvider);
    final busy = ref.watch(adminControllerProvider).busy;
    final all = ref.watch(disputesProvider).valueOrNull ?? const <Dispute>[];
    final wantOpen = filter == 'Open';
    final list = all.where((d) => d.isOpen == wantOpen).toList();

    return Scaffold(
      appBar: const TopBar('Disputes', back: false),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          ChipRow(
            labels: const ['Open', 'Resolved'],
            selected: filter,
            onSelected: (v) => ref.read(_disputeFilterProvider.notifier).state = v,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                if (list.isEmpty) const _Empty('Nothing here.', padding: 60),
                for (final d in list) ...[
                  AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const IconTile(Icons.flag_outlined,
                                bg: AppColors.dangerBg, fg: AppColors.danger, size: 52, radius: 14),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Booking ${d.bookingRef}',
                                      style: const TextStyle(
                                          fontSize: 17.5, fontWeight: FontWeight.w700)),
                                  Text('Reported by ${d.raisedByName}',
                                      style: const TextStyle(
                                          fontSize: 13.5, color: AppColors.muted)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Pill(d.status,
                                big: true,
                                bg: d.isOpen ? AppColors.dangerBg : AppColors.green100,
                                fg: d.isOpen ? AppColors.danger : AppColors.primaryDark),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(d.reason,
                            style: const TextStyle(fontSize: 14, color: AppColors.body)),
                        if (!d.isOpen && d.resolution.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('Resolution: ${d.resolution}',
                              style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark)),
                        ],
                        const SizedBox(height: 14),
                        if (d.isOpen)
                          PrimaryButton('Resolve',
                              height: 48, onPressed: busy ? null : () => _resolve(context, ref, d))
                        else
                          OutlineButtonX('Delete',
                              height: 48,
                              color: AppColors.danger,
                              onPressed: busy ? null : () => _delete(context, ref, d)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog that collects the resolution note; pops with the text.
class _ResolveDialog extends ConsumerStatefulWidget {
  const _ResolveDialog({required this.dispute});
  final Dispute dispute;

  @override
  ConsumerState<_ResolveDialog> createState() => _ResolveDialogState();
}

class _ResolveDialogState extends ConsumerState<_ResolveDialog> {
  final _formKey = GlobalKey<FormState>();
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) Navigator.of(context).pop(_note.text.trim());
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Resolve ${widget.dispute.bookingRef}'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: LabeledField('Resolution note',
                hint: 'What was decided?',
                icon: Icons.chat_bubble_outline,
                controller: _note,
                maxLines: 3,
                validator: (v) => Validators.required(v, 'Resolution note')),
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                minimumSize: const Size(48, 48), backgroundColor: AppColors.primary),
            onPressed: _submit,
            child: const Text('Resolve'),
          ),
        ],
      );
}

// ---- more ----------------------------------------------------------------------

/// Shortcuts, demo data loader and log out.
class AdminMoreScreen extends ConsumerWidget {
  const AdminMoreScreen({super.key});

  Future<void> _seed(BuildContext context, WidgetRef ref) async {
    final ok = await _confirm(
        context,
        'Load demo data?',
        'Adds sample equipment, experts and courses. Existing demo items are overwritten.',
        'Load',
        destructive: false);
    if (!ok || !context.mounted) return;
    final result = await ref.read(adminControllerProvider.notifier).seedDemoData();
    if (!context.mounted) return;
    showToast(context, result.ok ? 'Demo data loaded.' : result.error!);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(adminControllerProvider).busy;
    final rows = <(IconData, String, String, VoidCallback)>[
      (
        Icons.settings_outlined,
        'Settings',
        'Text size, notifications, district',
        () => context.push('/settings')
      ),
      (
        Icons.notifications_none,
        'Notifications',
        'Messages sent to you',
        () => context.push('/notifications')
      ),
      (
        Icons.cloud_upload_outlined,
        busy ? 'Loading…' : 'Load demo data',
        'Equipment, experts and courses',
        busy ? () {} : () => _seed(context, ref)
      ),
    ];
    return Scaffold(
      appBar: const TopBar('More', back: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final r in rows)
                  InkWell(
                    onTap: r.$4,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 64),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            IconTile(r.$1, bg: AppColors.green100, size: 44, radius: 12),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.$2,
                                      style: const TextStyle(
                                          fontSize: 16.5, fontWeight: FontWeight.w700)),
                                  Text(r.$3,
                                      style: const TextStyle(
                                          fontSize: 13.5, color: AppColors.muted)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.faint),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            color: AppColors.dangerBg,
            borderColor: AppColors.dangerBg,
            // The router sends the user to the login screen once the session ends.
            onTap: () => ref.read(authControllerProvider.notifier).signOut(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 32),
              child: Row(
                children: [
                  Icon(Icons.logout, color: AppColors.danger),
                  SizedBox(width: 12),
                  Text('Log out',
                      style: TextStyle(
                          fontSize: 16.5, fontWeight: FontWeight.w600, color: AppColors.danger)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text('NTIZA · Version 0.1.0',
                style: TextStyle(fontSize: 13, color: AppColors.muted)),
          ),
        ],
      ),
    );
  }
}
