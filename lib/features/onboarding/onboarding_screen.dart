import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ntiza_logo.dart';
import '../../core/widgets/primary_button.dart';

class _Slide {
  const _Slide(this.title, this.body, this.image);
  final String title;
  final String body;
  final String image;
}

// Photos from the approved prototype. Replaced by bundled assets before release.
const _slides = <_Slide>[
  _Slide(
    'Machinery within reach',
    'Find trusted agricultural equipment near your farm, without long searches.',
    'https://images.unsplash.com/photo-1692019007242-36158877ec96?auto=format&fit=crop&w=900&q=82',
  ),
  _Slide(
    'Book farming services',
    'Request tractors, ploughing, planting and harvesting in a few simple steps.',
    'https://images.unsplash.com/photo-1592805144716-feeccccef5ac?auto=format&fit=crop&w=800&q=82',
  ),
  _Slide(
    'Farm more productively',
    'Use mechanization, expert guidance and training to grow with confidence.',
    'https://images.unsplash.com/photo-1682773083912-ff5ee5fa557b?auto=format&fit=crop&w=900&q=82',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      context.go(Routes.login);
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_index];
    final photoHeight = math.max(390.0, MediaQuery.of(context).size.height * 0.54);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          SizedBox(
            height: photoHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => _SlidePhoto(url: _slides[i].image),
                ),
                const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x8506180E),
                          Color(0x0006180E),
                          Color(0x4D06180E),
                        ],
                        stops: [0, 0.45, 1],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const NtizaLogo(light: true),
                          _SkipButton(onTap: () => context.go(Routes.login)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 28, 26, 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MECHANIZATION FOR EVERY FARM',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    slide.title,
                    style: const TextStyle(
                      fontSize: 31,
                      height: 1.12,
                      letterSpacing: -1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    slide.body,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 15,
                      height: 1.65,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Dots(count: _slides.length, active: _index),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: _isLast ? 'Get started' : 'Continue',
                    showArrow: true,
                    onPressed: _next,
                  ),
                  Center(
                    child: TextButton(
                      style: TextButton.styleFrom(padding: const EdgeInsets.all(14)),
                      onPressed: () => context.go(Routes.home),
                      child: const Text('Explore demo'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlidePhoto extends StatelessWidget {
  const _SlidePhoto({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.greenDark,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.heroStart, AppColors.heroEnd],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x28FFFFFF),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Text(
            'Skip',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 6),
            width: i == active ? 26 : 6,
            height: 5,
            decoration: BoxDecoration(
              color: i == active ? AppColors.green : AppColors.dotInactive,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
      ],
    );
  }
}
