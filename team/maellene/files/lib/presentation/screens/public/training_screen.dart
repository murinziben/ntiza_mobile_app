import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../widgets/ui.dart';
import 'widgets.dart';

const _topics = ['All', 'Crops', 'Equipment', 'Irrigation', 'Business', 'Livestock'];

final _topicProvider = StateProvider.autoDispose<String>((ref) => 'All');

/// Free training courses, filterable by topic.
class TrainingScreen extends ConsumerWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topic = ref.watch(_topicProvider);

    return Scaffold(
      appBar: const TopBar('Training & Education', back: false),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          ChipRow(
            labels: _topics,
            selected: topic,
            onSelected: (v) => ref.read(_topicProvider.notifier).state = v,
          ),
          const SizedBox(height: 16),
          asyncSection(ref.watch(coursesProvider), (all) {
            final items = all.where((c) => topic == 'All' || c.topic == topic).toList();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  if (items.isEmpty) const EmptyNote('No courses in this topic yet.'),
                  for (final c in items) ...[
                    CourseCard(course: c),
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
