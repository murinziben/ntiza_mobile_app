import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/constants.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';

/// Text-size choices: label → scale factor stored in preferences.
const _textSizes = <String, double>{'Small': 0.9, 'Normal': 1.0, 'Large': 1.15};

/// App preferences. Every value is read from and written to
/// `settingsControllerProvider`, which saves it in SharedPreferences, so the
/// choices are restored the next time the app starts. Works for guests too.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final sizeLabel = _textSizes.entries
        .firstWhere((e) => e.value == settings.textScale,
            orElse: () => const MapEntry('Normal', 1.0))
        .key;

    return Scaffold(
      appBar: const TopBar('Settings'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          const _SectionLabel('Appearance'),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Text size',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 2, 16, 12),
                  child: Text('Makes text across the whole app smaller or larger.',
                      style: TextStyle(fontSize: 13.5, color: AppColors.muted)),
                ),
                ChipRow(
                  labels: _textSizes.keys.toList(),
                  selected: sizeLabel,
                  onSelected: (v) => controller.setTextScale(_textSizes[v] ?? 1.0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const _SectionLabel('Notifications'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SwitchListTile(
              value: settings.notificationsEnabled,
              activeTrackColor: AppColors.primary,
              title: const Text('Show notifications',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              subtitle: const Text('Booking, payment and training alerts',
                  style: TextStyle(fontSize: 13.5, color: AppColors.muted)),
              onChanged: controller.setNotificationsEnabled,
            ),
          ),
          const SizedBox(height: 22),
          const _SectionLabel('Marketplace'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Preferred district',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Padding(
                  padding: EdgeInsets.only(top: 2, bottom: 12),
                  child: Text('Equipment in this district is shown first.',
                      style: TextStyle(fontSize: 13.5, color: AppColors.muted)),
                ),
                DropdownButtonFormField<String>(
                  initialValue: districts.contains(settings.preferredDistrict)
                      ? settings.preferredDistrict
                      : '',
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.muted),
                  ),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('All districts')),
                    for (final d in districts) DropdownMenuItem(value: d, child: Text(d)),
                  ],
                  onChanged: (v) => controller.setPreferredDistrict(v ?? ''),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const _SectionLabel('About'),
          const AppCard(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                _InfoRow('App version', '1.0.0'),
                Divider(height: 1),
                _InfoRow('Support', 'support@ntiza.app'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small grey heading above a group of settings.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Text(text.toUpperCase(),
            style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: AppColors.muted)),
      );
}

/// Read-only label/value row.
class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 15.5))),
            Flexible(
              child: Text(value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 15, color: AppColors.muted)),
            ),
          ],
        ),
      );
}
