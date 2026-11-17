import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';
import 'widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipment = ref.watch(equipmentProvider).valueOrNull ?? const <Equipment>[];
    final experts = ref.watch(expertsProvider).valueOrNull ?? const <Expert>[];
    final courses = ref.watch(coursesProvider).valueOrNull ?? const <Course>[];
    final signedIn = ref.watch(signedInProvider);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Hero(signedIn: signedIn),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Quick('Equipment', Icons.agriculture_outlined, AppColors.green100,
                    AppColors.primaryDark, () => context.go('/equipment')),
                _Quick('Experts', Icons.groups_2_outlined, AppColors.blueBg, AppColors.blue,
                    () => context.go('/experts')),
                _Quick('Training', Icons.menu_book_outlined, AppColors.amberBg, AppColors.amber,
                    () => context.go('/training')),
                _Quick('Agents', Icons.smartphone_outlined, AppColors.purpleBg,
                    AppColors.purple, () => context.push('/login')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 26, 16, 14),
            child: SectionHeader('Equipment Marketplace',
                action: 'See all', onAction: () => context.go('/equipment')),
          ),
          SizedBox(
            height: 300,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: equipment.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, i) => SizedBox(
                width: 276,
                child: EquipmentTile(item: equipment[i], compact: true),
              ),
            ),
          ),
          if (equipment.isEmpty) const EmptyNote('No equipment listed yet.'),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 28, 16, 14),
            child: Text('How NTIZA Works',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: AppCard(
              padding: EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: Column(
                children: <Widget>[
                  _Step(1, 'Farmer Requests', 'Submit a request for equipment or an expert'),
                  _Step(2, 'Platform Matches', 'We connect you with an available provider'),
                  _Step(3, 'Payment Processed', 'Pay securely with MTN MoMo or Airtel Money'),
                  _Step(4, 'Service Delivered', 'Equipment or expert arrives at your farm'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
            child: SectionHeader('Agricultural Experts',
                action: 'See all', onAction: () => context.go('/experts')),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (final e in experts.take(3)) ...[
                  ExpertCard(expert: e, onBook: () => goBookExpert(context, ref, e.id)),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: SectionHeader('Training & Education',
                action: 'See all', onAction: () => context.go('/training')),
          ),
          if (courses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CourseCard(course: courses.first, onTap: () => context.go('/training')),
            ),
          if (!signedIn)
            Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ready to grow with NTIZA?',
                      style: TextStyle(
                          color: Colors.white, fontSize: 21, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  const Text('Join thousands of farmers, owners and experts across Rwanda.',
                      style: TextStyle(color: Colors.white, fontSize: 16, height: 1.45)),
                  const SizedBox(height: 18),
                  OutlineButtonX('Create Free Account',
                      expand: false, onPressed: () => context.push('/register')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Photo header with the headline, two calls to action and a bell/settings button.
class _Hero extends StatelessWidget {
  const _Hero({required this.signedIn});
  final bool signedIn;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          SizedBox(
            height: 470,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const AssetPhoto('hero_villagers.jpg'),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x99000000), Color(0x33000000), Color(0xB3000000)],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const LogoLockup(light: true, size: 40),
                            // Signed-in users see notifications; guests get settings.
                            Material(
                              color: const Color(0x55FFFFFF),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () =>
                                    context.push(signedIn ? '/notifications' : '/settings'),
                                child: SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: Center(
                                    child: signedIn
                                        ? const BellIcon(light: true)
                                        : const Icon(Icons.settings_outlined,
                                            color: Colors.white,
                                            semanticLabel: 'Settings'),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Text(
                            'Connecting Farmers to Agricultural Equipment and Experts',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                                height: 1.2,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        const Text(
                            'Access mechanization services, agricultural expertise, and training through one platform.',
                            style: TextStyle(color: Colors.white, fontSize: 16, height: 1.4)),
                        const SizedBox(height: 16),
                        Row(children: [
                          Expanded(
                              child: PrimaryButton('Browse Equipment',
                                  onPressed: () => context.go('/equipment'))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: OutlineButtonX('Book Services',
                                  onPressed: () =>
                                      context.push(signedIn ? '/experts' : '/login'))),
                        ]),
                        const SizedBox(height: 56),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -28),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1A000000), blurRadius: 14, offset: Offset(0, 4))
                  ],
                ),
                child: const SearchField(hint: 'Search tractors, experts, courses…'),
              ),
            ),
          ),
        ],
      );
}

/// Round shortcut button on the home screen.
class _Quick extends StatelessWidget {
  const _Quick(this.label, this.icon, this.bg, this.fg, this.onTap);
  final String label;
  final IconData icon;
  final Color bg, fg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              IconTile(icon, bg: bg, fg: fg, size: 62, radius: 20),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
}

class _Step extends StatelessWidget {
  const _Step(this.n, this.title, this.sub);
  final int n;
  final String title, sub;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: Text('$n',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(sub, style: const TextStyle(fontSize: 13.5, color: AppColors.muted)),
                ],
              ),
            ),
          ],
        ),
      );
}
