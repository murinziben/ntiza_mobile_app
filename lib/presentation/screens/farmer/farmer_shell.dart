import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../public/public_shell.dart';

const farmerNav = [
  NavItem('Home', Icons.grid_view_outlined),
  NavItem('Book', Icons.agriculture_outlined),
  NavItem('Bookings', Icons.calendar_today_outlined),
  NavItem('Learn', Icons.menu_book_outlined),
  NavItem('Profile', Icons.person_outline),
];

class FarmerShell extends StatelessWidget {
  const FarmerShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: shell,
        bottomNavigationBar: NtizaBottomNav(
          items: farmerNav,
          index: shell.currentIndex,
          onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        ),
      );
}
