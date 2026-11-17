import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';

/// Shows a spinner while loading and a friendly message on error, otherwise
/// builds [data]. Used by every list screen so loading/error states are uniform.
Widget asyncSection<T>(AsyncValue<T> value, Widget Function(T data) data) => value.when(
      data: data,
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Center(
          child: Text('Could not load data. Check your connection and try again.',
              textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
        ),
      ),
    );

/// Centered grey message for empty lists.
class EmptyNote extends StatelessWidget {
  const EmptyNote(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
        child: Center(
          child: Text(text,
              textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
        ),
      );
}

/// Opens the expert booking flow, or the login screen for guests.
void goBookExpert(BuildContext context, WidgetRef ref, String expertId) {
  context.push(ref.read(signedInProvider) ? '/farmer/book-expert/$expertId' : '/login');
}

/// Marketplace card for one machine.
class EquipmentTile extends StatelessWidget {
  const EquipmentTile({super.key, required this.item, this.compact = false});
  final Equipment item;
  final bool compact;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: EdgeInsets.zero,
        onTap: () => context.push('/equipment/${item.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AssetPhoto(item.image, height: compact ? 118 : 160),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 17.5, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      StatusChip(item.statusLabel),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 17, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(item.place,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, color: AppColors.muted)),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text.rich(TextSpan(children: [
                          TextSpan(
                              text: rwf(item.price),
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark)),
                          TextSpan(
                              text: ' / ${item.unit}',
                              style: const TextStyle(fontSize: 14, color: AppColors.muted)),
                        ])),
                      ),
                      if (!compact) ...[
                        const SizedBox(width: 8),
                        PrimaryButton('Book Now',
                            expand: false,
                            height: 48,
                            onPressed: () => context.push('/equipment/${item.id}')),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

/// Card for one agricultural expert. Pass [onBook] to show the Book button.
class ExpertCard extends StatelessWidget {
  const ExpertCard({super.key, required this.expert, this.onBook});
  final Expert expert;
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            InitialsAvatar(initialsOf(expert.name), size: 62),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expert.name,
                      style: const TextStyle(fontSize: 17.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(expert.field,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark)),
                  const SizedBox(height: 3),
                  RatingLine(expert.rating, '${expert.years} years experience'),
                  const SizedBox(height: 3),
                  Text(
                    expert.accepting
                        ? '${rwf(expert.fee)} / ${expert.sessionMinutes} min'
                        : 'Not taking new consultations',
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: expert.accepting ? AppColors.body : AppColors.danger),
                  ),
                ],
              ),
            ),
            if (onBook != null) ...[
              const SizedBox(width: 8),
              SoftButton('Book', onPressed: expert.accepting ? onBook : null),
            ],
          ],
        ),
      );
}

/// Card for one training course.
class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.course, this.onTap});
  final Course course;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final intermediate = course.level == 'Intermediate';
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssetPhoto(course.image, height: 160),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(spacing: 8, runSpacing: 8, children: [
                  Pill(course.level,
                      big: true,
                      bg: intermediate ? AppColors.blueBg : AppColors.green100,
                      fg: intermediate ? AppColors.blue : AppColors.primaryDark),
                  Pill(course.topic, big: true, bg: AppColors.neutral, fg: AppColors.body),
                ]),
                const SizedBox(height: 12),
                Text(course.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.play_arrow, size: 20, color: AppColors.muted),
                  const SizedBox(width: 6),
                  Text('${course.lessons} lessons · Free',
                      style: const TextStyle(fontSize: 14, color: AppColors.muted)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
