import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import 'routes.dart';

class NavigationShell extends StatelessWidget {
  const NavigationShell({super.key, required this.child});

  final Widget child;

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/weekday') ||
        location.startsWith('/place') ||
        location.startsWith('/area') ||
        location.startsWith('/customer')) {
      return 1;
    }
    return 0; // default to Home/Dashboard
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == 0) {
      context.go(Routes.dashboard);
    } else {
      context.go(Routes.weekday('Thursday')); // Route Explorer start page
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selectedIndex = _getSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(Icons.home, color: Color(0xFF0F5D6B)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            activeIcon: Icon(Icons.map, color: Color(0xFF0F5D6B)),
            label: 'Routes',
          ),
        ],
      ),
    );
  }
}
