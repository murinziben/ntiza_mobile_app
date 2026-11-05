import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../widgets/ui.dart';

/// First-launch screen. Leaving it saves `onboardingSeen`, so the next app
/// start opens the home screen directly.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  Future<void> _leave(BuildContext context, WidgetRef ref, {required bool login}) async {
    await ref.read(settingsControllerProvider.notifier).markOnboardingSeen();
    if (!context.mounted) return;
    if (login) {
      context.push('/login');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF166534), Color(0xFF14532D), Color(0xFF052E16)],
            ),
          ),
          child: SafeArea(
            // Scrolls in landscape / small screens instead of overflowing.
            child: LayoutBuilder(
              builder: (context, box) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: box.maxHeight),
                  child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LogoLockup(light: true, size: 48),
                  const SizedBox(height: 28),
                  const Text('Connecting Farmers to Agricultural Equipment and Experts',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          height: 1.2,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 18),
                  const Text(
                      'Book tractors, harvesters and certified agri-experts, pay with Mobile Money and learn new skills — all in one app.',
                      style: TextStyle(color: Colors.white, fontSize: 17, height: 1.45)),
                  const SizedBox(height: 22),
                  Row(children: [
                    Container(
                        width: 48,
                        height: 10,
                        decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            borderRadius: BorderRadius.circular(9))),
                    for (var i = 0; i < 2; i++)
                      Container(
                          margin: const EdgeInsets.only(left: 8),
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                              color: Color(0x80FFFFFF), shape: BoxShape.circle)),
                  ]),
                  const SizedBox(height: 28),
                  PrimaryButton('Get Started',
                      height: 52, onPressed: () => _leave(context, ref, login: false)),
                  const SizedBox(height: 14),
                  OutlineButtonX('I already have an account',
                      height: 52, onPressed: () => _leave(context, ref, login: true)),
                  const SizedBox(height: 18),
                  const Center(
                    child: Text('English · Kinyarwanda',
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                ],
              ),
            ),
                ),
              ),
            ),
          ),
        ),
      );
}
