import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/widgets/placeholder_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Explore',
      actions: {
        'Equipment card → Detail': () => context.push(Routes.equipment('demo')),
        'Bell → Notifications': () => context.go(Routes.notifications),
      },
    );
  }
}
