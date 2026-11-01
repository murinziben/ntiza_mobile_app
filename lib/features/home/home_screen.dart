import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/widgets/placeholder_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Home',
      actions: {
        'Search / Find equipment → Explore': () => context.go(Routes.explore),
        'Equipment card → Detail': () => context.push(Routes.equipment('demo')),
        'Bell → Notifications': () => context.go(Routes.notifications),
        'Booking strip → Bookings': () => context.go(Routes.bookings),
      },
    );
  }
}
