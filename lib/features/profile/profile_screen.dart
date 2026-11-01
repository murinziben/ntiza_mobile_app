import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/widgets/placeholder_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Profile',
      actions: {
        'My bookings → Bookings': () => context.go(Routes.bookings),
        'Log out → Login': () => context.go(Routes.login),
      },
    );
  }
}
