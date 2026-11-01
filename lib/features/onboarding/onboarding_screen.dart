import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/widgets/placeholder_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Onboarding',
      actions: {
        'Continue / Get started → Login': () => context.go(Routes.login),
        'Skip → Login': () => context.go(Routes.login),
        'Explore demo → Home': () => context.go(Routes.home),
      },
    );
  }
}
