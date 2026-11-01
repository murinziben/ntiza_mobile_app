import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/widgets/placeholder_screen.dart';

class EquipmentDetailScreen extends StatelessWidget {
  const EquipmentDetailScreen({super.key, required this.equipmentId});

  final String equipmentId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Equipment · $equipmentId',
      showBack: true,
      actions: {
        'Book now → Booking': () => context.push(Routes.booking(equipmentId)),
        'Back': () => context.pop(),
      },
    );
  }
}
