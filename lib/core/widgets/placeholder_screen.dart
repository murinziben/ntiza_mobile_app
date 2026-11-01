import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Temporary body for Step 2 stubs. Replaced screen by screen in Step 3.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.actions,
    this.showBack = false,
  });

  final String title;
  final bool showBack;

  /// label -> callback, rendered as buttons so every route is reachable.
  final Map<String, VoidCallback> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        automaticallyImplyLeading: showBack,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const Text(
              'PLACEHOLDER · STEP 2',
              style: TextStyle(
                color: AppColors.green,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            for (final entry in actions.entries) ...[
              ElevatedButton(onPressed: entry.value, child: Text(entry.key)),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
