import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/entities.dart';
import '../../widgets/ui.dart';

/// Compact booking row used on the dashboard and bookings list. Works for both
/// machine hires (photo) and expert consultations (icon).
class BookingRow extends StatelessWidget {
  const BookingRow({super.key, required this.booking, required this.subtitle});
  final Booking booking;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => context.push('/farmer/booking/${b.ref}'),
      child: Row(
        children: [
          if (b.expert)
            const IconTile(Icons.groups_2_outlined,
                size: 60, radius: 12, bg: AppColors.purpleBg, fg: AppColors.purple)
          else
            AssetPhoto(b.image, width: 60, height: 60, radius: 12),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13.5, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusChip(b.status),
        ],
      ),
    );
  }
}
