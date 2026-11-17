import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';
import 'widgets.dart';

const _cats = ['All', 'Crops', 'Soil', 'Pests', 'Irrigation'];

final _categoryProvider = StateProvider.autoDispose<String>((ref) => 'All');

/// Directory of agricultural experts, filterable by category.
class ExpertsScreen extends ConsumerWidget {
  const ExpertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = ref.watch(_categoryProvider);

    return Scaffold(
      appBar: const TopBar('Agricultural Experts', back: false),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Text(
                'Connect with certified agricultural professionals for expert advice and consultation.',
                style: TextStyle(fontSize: 16, height: 1.45, color: AppColors.muted)),
          ),
          ChipRow(
            labels: _cats,
            selected: cat,
            onSelected: (v) => ref.read(_categoryProvider.notifier).state = v,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: AppColors.primaryDark, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Pill('Pay per session',
                            bg: AppColors.green100, fg: AppColors.primaryDark),
                        SizedBox(height: 10),
                        Text('Not sure which expert you need?',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                height: 1.25,
                                fontWeight: FontWeight.w700)),
                        SizedBox(height: 6),
                        Text('Pick a category, then book a phone call, video call or farm visit.',
                            style: TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                        color: const Color(0x33FFFFFF),
                        borderRadius: BorderRadius.circular(18)),
                    child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 30),
                  ),
                ],
              ),
            ),
          ),
          asyncSection(ref.watch(expertsProvider), (all) {
            final items = all.where((e) => cat == 'All' || e.category == cat).toList();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  if (items.isEmpty) const EmptyNote('No experts in this category yet.'),
                  for (final e in items) ...[
                    ExpertCard(expert: e, onBook: () => goBookExpert(context, ref, e.id)),
                    const SizedBox(height: 12),
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
