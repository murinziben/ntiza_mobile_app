import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/ui.dart';

/// Account tab shown before login.
class GuestAccountScreen extends StatelessWidget {
  const GuestAccountScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const TopBar('Account', back: false),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 24),
            const Center(child: LogoMark(size: 72)),
            const SizedBox(height: 18),
            const Center(
              child: Text('Welcome to NTIZA',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text('Log in to book equipment, consult experts and track payments.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, height: 1.45, color: AppColors.muted)),
            ),
            const SizedBox(height: 26),
            PrimaryButton('Log In', height: 52, onPressed: () => context.push('/login')),
            const SizedBox(height: 12),
            OutlineButtonX('Create an Account',
                height: 52, onPressed: () => context.push('/register')),
            const SizedBox(height: 24),
            AppCard(
              padding: EdgeInsets.zero,
              onTap: () => context.push('/settings'),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconTile(Icons.settings_outlined, bg: AppColors.green50, size: 40, radius: 12),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text('Settings',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                      Icon(Icons.chevron_right, color: AppColors.faint),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
