import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/constants.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';
import 'widgets.dart';

const _types = ['All', 'Tractor', 'Harvester', 'Pump', 'Planter', 'Tiller', 'Sheller'];
const _allDistricts = 'All locations';

// Ephemeral filter state lives in providers, not in widget State.
final _typeProvider = StateProvider.autoDispose<String>((ref) => 'All');
final _queryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Starts on the district saved in Settings, but can be changed here.
final _districtProvider = StateProvider.autoDispose<String>((ref) {
  final saved = ref.read(settingsControllerProvider).preferredDistrict;
  return saved.isEmpty ? _allDistricts : saved;
});

/// Browse and filter every machine on the platform.
class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(_typeProvider);
    final district = ref.watch(_districtProvider);
    final q = ref.watch(_queryProvider).trim().toLowerCase();

    return Scaffold(
      appBar: const TopBar('Equipment Marketplace', back: false),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: SearchField(
              hint: 'Search equipment',
              filter: false,
              onChanged: (v) => ref.read(_queryProvider.notifier).state = v,
            ),
          ),
          ChipRow(
            labels: _types,
            selected: type,
            onSelected: (v) => ref.read(_typeProvider.notifier).state = v,
          ),
          const SizedBox(height: 10),
          ChipRow(
            labels: const [_allDistricts, ...districts],
            selected: district,
            onSelected: (v) => ref.read(_districtProvider.notifier).state = v,
          ),
          asyncSection(ref.watch(equipmentProvider), (all) {
            final items = all
                .where((e) =>
                    (type == 'All' || e.type == type) &&
                    (district == _allDistricts || e.district == district) &&
                    (q.isEmpty ||
                        e.name.toLowerCase().contains(q) ||
                        e.district.toLowerCase().contains(q)))
                .toList();
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text('${items.length} machines found',
                        style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.muted)),
                  ),
                  if (items.isEmpty) const EmptyNote('No equipment matches your filters.'),
                  for (final e in items) ...[
                    EquipmentTile(item: e),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
