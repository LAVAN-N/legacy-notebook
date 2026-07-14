import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/floating_bottom_nav.dart';
import 'routes.dart';

/// Represents a breadcrumb in the navigation hierarchy
class BreadcrumbItem {
  final String label;
  final String? route; // null if it's the current page (not a link)

  BreadcrumbItem({required this.label, this.route});
}

/// Builds breadcrumb list from current route
List<BreadcrumbItem> _buildBreadcrumbs(GoRouterState state) {
  final path = state.uri.path;
  final params = state.pathParameters;

  if (path == Routes.dashboard || path == '/inventory' || path == '/transactions' || path == '/profile' || path.contains('/sale') || path.contains('/collect')) {
    return [];
  }

  final breadcrumbs = [BreadcrumbItem(label: 'Dashboard', route: Routes.dashboard)];
  
  if (path.startsWith('/inventory/')) {
    breadcrumbs.add(BreadcrumbItem(label: 'Inventory', route: '/inventory'));
    final categoryId = params['categoryId'];
    if (categoryId != null && categoryId.isNotEmpty) {
      breadcrumbs.add(BreadcrumbItem(label: categoryId));
    }
    return breadcrumbs;
  }

  final day = params['day'] ?? 'Monday';
  
  if (path.contains('/weekday/')) {
    breadcrumbs.add(BreadcrumbItem(
      label: day, 
      route: path.contains('/place/') ? Routes.weekday(day) : null
    ));
  }

  if (path.contains('/place/')) {
    final placeId = params['placeId'] ?? '';
    breadcrumbs.add(BreadcrumbItem(
      label: 'Place $placeId',
      route: path.contains('/area/') ? Routes.place(day, placeId) : null
    ));
  }

  if (path.contains('/area/')) {
    final areaId = params['areaId'] ?? '';
    final placeId = params['placeId'] ?? '';
    breadcrumbs.add(BreadcrumbItem(
      label: 'Area $areaId',
      route: path.contains('/customer/') ? Routes.area(day, placeId, areaId) : null
    ));
  }

  if (path.contains('/customer/')) {
    final customerId = params['customerId'] ?? '';
    breadcrumbs.add(BreadcrumbItem(
      label: 'Client $customerId',
      route: null
    ));
  }

  return breadcrumbs;
}

/// Computes the back target from current URL params
String? _computeBackTarget(GoRouterState state) {
  final path = state.uri.path;
  final params = state.pathParameters;

  if (path == Routes.dashboard) {
    return null;
  }
  if (path == '/transactions' || path == '/profile' || path == '/inventory') {
    return Routes.dashboard;
  }
  if (path.startsWith('/inventory/')) {
    return '/inventory';
  }

  if (path == Routes.newClient) {
    return Routes.dashboard;
  }

  if (path.contains('/sale') || path.contains('/collect')) {
    return Routes.customer(
      params['day'] ?? 'Monday',
      params['placeId'] ?? '',
      params['areaId'] ?? '',
      params['customerId'] ?? '',
    );
  }
  if (path.contains('/customer/')) {
    return Routes.area(
      params['day'] ?? 'Monday',
      params['placeId'] ?? '',
      params['areaId'] ?? '',
    );
  }
  if (path.contains('/area/')) {
    return Routes.place(
      params['day'] ?? 'Monday',
      params['placeId'] ?? '',
    );
  }
  if (path.contains('/place/')) {
    return Routes.weekday(params['day'] ?? 'Monday');
  }
  if (path.contains('/weekday/')) {
    return Routes.dashboard;
  }
  
  return null;
}

class NavigationShell extends StatelessWidget {
  const NavigationShell({super.key, required this.child});

  final Widget child;

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location == Routes.dashboard) {
      return 0; // Dashboard
    } else if (location.startsWith('/inventory')) {
      return 1; // Inventory
    } else if (location.startsWith('/transactions')) {
      return 2; // Transactions
    } else if (location.startsWith('/profile')) {
      return 3; // Profile
    }
    // For routes like /weekday, /place, /area, /customer, we don't highlight any tab
    // (they live in the shell but are accessed via breadcrumbs, not nav)
    return 0;
  }

  void _onBottomNavTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(Routes.dashboard);
        break;
      case 1:
        context.go('/inventory');
        break;
      case 2:
        context.go('/transactions');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  bool _shouldShowBottomNav(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    // Hide nav on splash, full-screen forms, and modal routes
    if (path == '/splash' ||
        path == '/customer/new' ||
        path.contains('/collect') ||
        path.contains('/sale') ||
        path.startsWith('/new-client')) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);
    final showBottomNav = _shouldShowBottomNav(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: showBottomNav
          ? FloatingBottomNav(
              selectedIndex: selectedIndex,
              onTap: (index) => _onBottomNavTapped(context, index),
            )
          : null,
    );
  }
}

// Extension for easier breadcrumb and back-nav computation
extension NavigationExtension on BuildContext {
  List<BreadcrumbItem> getBreadcrumbs() {
    return _buildBreadcrumbs(GoRouterState.of(this));
  }

  String? getBackTarget() {
    return _computeBackTarget(GoRouterState.of(this));
  }
}
