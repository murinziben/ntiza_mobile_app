import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/widgets/placeholder_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Login / Register',
      actions: {
        'Sign in → Home': () => context.go(Routes.home),
        'Back → Onboarding': () => context.go(Routes.onboarding),
      },
    );
  }
}
