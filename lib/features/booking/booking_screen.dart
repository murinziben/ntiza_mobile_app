import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/widgets/placeholder_screen.dart';

/// Step 3 will turn this into the 3-step flow (details → review → success).
class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key, required this.equipmentId});

  final String equipmentId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Request booking',
      showBack: true,
      actions: {
        'Finish → My bookings': () => context.go(Routes.bookings),
        'Back to home': () => context.go(Routes.home),
      },
    );
  }
}
