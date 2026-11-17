import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

class NavItem {
  const NavItem(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Bottom navigation used by every role shell.
class NtizaBottomNav extends StatelessWidget {
  const NtizaBottomNav({super.key, required this.items, required this.index, required this.onTap});
  final List<NavItem> items;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: InkWell(
                      onTap: () => onTap(i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(items[i].icon,
                              size: 25,
                              color: i == index ? AppColors.primary : AppColors.faint),
                          const SizedBox(height: 3),
                          Text(items[i].label,
                              style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: i == index ? FontWeight.w600 : FontWeight.w500,
                                  color: i == index ? AppColors.primary : AppColors.faint)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}

const publicNav = [
  NavItem('Home', Icons.home_outlined),
  NavItem('Equipment', Icons.agriculture_outlined),
  NavItem('Experts', Icons.groups_2_outlined),
  NavItem('Training', Icons.menu_book_outlined),
  NavItem('Account', Icons.person_outline),
];

class PublicShell extends StatelessWidget {
  const PublicShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: shell,
        bottomNavigationBar: NtizaBottomNav(
          items: publicNav,
          index: shell.currentIndex,
          onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        ),
      );
}
