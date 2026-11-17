import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';

/// Full description of one machine with a sticky "Book Now" bar.
class EquipmentDetailScreen extends ConsumerWidget {
  const EquipmentDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = ref.watch(equipmentByIdProvider(id));
    if (e == null) {
      return const Scaffold(
        appBar: TopBar('Equipment'),
        body: Center(child: Text('This machine is no longer listed.')),
      );
    }
    final signedIn = ref.watch(signedInProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 280,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AssetPhoto(e.image),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: _RoundBtn(
                              Icons.chevron_left,
                              'Back',
                              () => context.canPop() ? context.pop() : context.go('/equipment'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -26),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(e.name,
                                  style: const TextStyle(
                                      fontSize: 24, fontWeight: FontWeight.w800)),
                            ),
                            const SizedBox(width: 8),
                            StatusChip(e.statusLabel),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(children: [
                          const Icon(Icons.location_on, size: 20, color: AppColors.muted),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                                e.sector.isEmpty ? e.district : '${e.district} · ${e.sector} sector',
                                style: const TextStyle(fontSize: 16, color: AppColors.muted)),
                          ),
                        ]),
                        const SizedBox(height: 16),
                        _OwnerCard(equipment: e),
                        if (e.specs.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [for (final s in e.specs) _SpecBox(spec: s)],
                          ),
                        ],
                        const SizedBox(height: 22),
                        const Text('About',
                            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        Text(e.about.isEmpty ? 'No description provided.' : e.about,
                            style: const TextStyle(
                                fontSize: 16, height: 1.5, color: AppColors.body)),
                        if (!e.available) ...[
                          const SizedBox(height: 18),
                          _UnavailableNote(status: e.statusLabel),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rwf(e.price),
                            style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark)),
                        Text('per ${e.unit}',
                            style: const TextStyle(fontSize: 13.5, color: AppColors.muted)),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: PrimaryButton(
                        e.available ? 'Book Now' : 'Not available',
                        height: 54,
                        onPressed: e.available
                            ? () => context.push(signedIn ? '/farmer/book/${e.id}' : '/login')
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Owner name, verified badge and completed-job count.
class _OwnerCard extends StatelessWidget {
  const _OwnerCard({required this.equipment});
  final Equipment equipment;

  @override
  Widget build(BuildContext context) {
    final name = equipment.ownerName.isEmpty ? 'NTIZA partner' : equipment.ownerName;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration:
          BoxDecoration(color: AppColors.page, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          InitialsAvatar(initialsOf(name), size: 54, bg: AppColors.primary, fg: Colors.white),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700)),
                Text('Verified owner · ${equipment.jobs} jobs completed',
                    style: const TextStyle(fontSize: 13, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecBox extends StatelessWidget {
  const _SpecBox({required this.spec});
  final Spec spec;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minWidth: 96),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(spec.key, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            const SizedBox(height: 4),
            Text(spec.value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

/// Explains why the Book button is disabled.
class _UnavailableNote extends StatelessWidget {
  const _UnavailableNote({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.amberBg, borderRadius: BorderRadius.circular(14)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: AppColors.amberText),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                  'This machine is currently ${status.toLowerCase()} and cannot be booked. '
                  'Please check back later or browse other equipment.',
                  style: const TextStyle(color: AppColors.amberText, fontSize: 14, height: 1.4)),
            ),
          ],
        ),
      );
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn(this.icon, this.label, this.onTap);
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: AppColors.ink, semanticLabel: label),
          ),
        ),
      );
}
