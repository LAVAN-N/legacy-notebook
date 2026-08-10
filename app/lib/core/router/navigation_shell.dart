import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/floating_bottom_nav.dart';
import 'routes.dart';
import '../../data/models/customer.dart';
import '../../data/providers.dart';

/// Represents a breadcrumb in the navigation hierarchy
class BreadcrumbItem {
  final String label;
  final String? route; // null if it's the current page (not a link)

  BreadcrumbItem({required this.label, this.route});
}

String _getWeekdayNameById(String id) {
  final map = {
    'w-1': 'Monday',
    'w-2': 'Tuesday',
    'w-3': 'Wednesday',
    'w-4': 'Thursday',
    'w-5': 'Friday',
    'w-6': 'Saturday',
    'w-7': 'Sunday',
  };
  return map[id] ?? 'Monday';
}

String _getPlaceName(BuildContext context, String placeId) {
  try {
    final container = ProviderScope.containerOf(context);
    final placesAsync = container.read(placesStreamProvider);
    final places = placesAsync.value ?? [];
    final match = places.firstWhere((p) => p.id == placeId);
    return match.name;
  } catch (_) {
    return 'Place $placeId';
  }
}

String _getAreaName(BuildContext context, String areaId) {
  try {
    final container = ProviderScope.containerOf(context);
    final areasAsync = container.read(areasStreamProvider);
    final areas = areasAsync.value ?? [];
    final match = areas.firstWhere((a) => a.id == areaId);
    return match.name;
  } catch (_) {
    return 'Area $areaId';
  }
}

String _getCustomerName(BuildContext context, String customerId) {
  try {
    final container = ProviderScope.containerOf(context);
    final customersAsync = container.read(customersStreamProvider);
    final customers = customersAsync.value ?? [];
    final match = customers.firstWhere((c) => c.id == customerId);
    return match.name;
  } catch (_) {
    return 'Client $customerId';
  }
}

/// Builds breadcrumb list from current route
List<BreadcrumbItem> _buildBreadcrumbs(BuildContext context, GoRouterState state) {
  final path = state.uri.path;
  final params = state.pathParameters;
  final queryParams = state.uri.queryParameters;

  if (path == Routes.dashboard ||
      path == '/inventory' ||
      path == '/transactions' ||
      path == '/profile' ||
      path.contains('/collect')) {
    return [];
  }

  // 1. Create & Edit Client Form
  if (path == Routes.newClient) {
    final customer = state.extra as Customer?;
    if (customer == null) {
      // Create Client
      return [
        BreadcrumbItem(label: 'Dashboard', route: Routes.dashboard),
        BreadcrumbItem(label: 'Client'),
      ];
    } else {
      // Edit Client
      final source = queryParams['source'] ?? '';
      final parentSource = queryParams['parent_source'] ?? '';
      if (source == 'sale') {
        final day = _getWeekdayNameById(customer.weekdayId);
        final clientRoute = Routes.customer(day, customer.placeId, customer.areaId, customer.id);
        final saleRoute = '${Routes.sale(day, customer.placeId, customer.areaId, customer.id)}?source=$parentSource';
        
        if (parentSource == 'create') {
          return [
            BreadcrumbItem(label: 'Dashboard', route: Routes.dashboard),
            BreadcrumbItem(label: 'Client', route: clientRoute),
            BreadcrumbItem(label: 'New Sale', route: saleRoute),
            BreadcrumbItem(label: 'Edit'),
          ];
        } else {
          return [
            BreadcrumbItem(label: 'Dashboard', route: Routes.dashboard),
            BreadcrumbItem(label: day, route: Routes.weekday(day)),
            BreadcrumbItem(label: _getPlaceName(context, customer.placeId), route: Routes.place(day, customer.placeId)),
            BreadcrumbItem(label: _getAreaName(context, customer.areaId), route: Routes.area(day, customer.placeId, customer.areaId)),
            BreadcrumbItem(label: customer.name, route: clientRoute),
            BreadcrumbItem(label: 'New Sale', route: saleRoute),
            BreadcrumbItem(label: 'Edit'),
          ];
        }
      } else {
        // Edit from client card
        final day = _getWeekdayNameById(customer.weekdayId);
        final clientRoute = Routes.customer(day, customer.placeId, customer.areaId, customer.id);
        return [
          BreadcrumbItem(label: 'Dashboard', route: Routes.dashboard),
          BreadcrumbItem(label: day, route: Routes.weekday(day)),
          BreadcrumbItem(label: _getPlaceName(context, customer.placeId), route: Routes.place(day, customer.placeId)),
          BreadcrumbItem(label: _getAreaName(context, customer.areaId), route: Routes.area(day, customer.placeId, customer.areaId)),
          BreadcrumbItem(label: customer.name, route: clientRoute),
          BreadcrumbItem(label: 'Edit'),
        ];
      }
    }
  }

  // 2. New Sale
  if (path.contains('/sale')) {
    final day = params['day'] ?? 'Monday';
    final placeId = params['placeId'] ?? '';
    final areaId = params['areaId'] ?? '';
    final customerId = params['customerId'] ?? '';
    final source = queryParams['source'] ?? '';
    
    if (source == 'transactions') {
      return [
        BreadcrumbItem(label: 'Dashboard', route: Routes.dashboard),
        BreadcrumbItem(label: 'Transactions', route: '/transactions'),
        BreadcrumbItem(label: _getCustomerName(context, customerId), route: '${Routes.customer(day, placeId, areaId, customerId)}?source=transactions'),
        BreadcrumbItem(label: 'New Sale'),
      ];
    } else if (source == 'clients') {
      return [
        BreadcrumbItem(label: 'Dashboard', route: Routes.dashboard),
        BreadcrumbItem(label: 'Clients', route: '/profile'),
        BreadcrumbItem(label: _getCustomerName(context, customerId), route: '${Routes.customer(day, placeId, areaId, customerId)}?source=clients'),
        BreadcrumbItem(label: 'New Sale'),
      ];
    } else if (source == 'create') {
      return [
        BreadcrumbItem(label: 'Dashboard', route: Routes.dashboard),
        BreadcrumbItem(label: _getCustomerName(context, customerId), route: Routes.customer(day, placeId, areaId, customerId)),
        BreadcrumbItem(label: 'New Sale'),
      ];
    } else {
      // Follows along its previous screen (client details: Dashboard -> Day -> Place -> Area -> Client -> New Sale)
      return [
        BreadcrumbItem(label: 'Dashboard', route: Routes.dashboard),
        BreadcrumbItem(label: day, route: Routes.weekday(day)),
        BreadcrumbItem(label: _getPlaceName(context, placeId), route: Routes.place(day, placeId)),
        BreadcrumbItem(label: _getAreaName(context, areaId), route: Routes.area(day, placeId, areaId)),
        BreadcrumbItem(label: _getCustomerName(context, customerId), route: Routes.customer(day, placeId, areaId, customerId)),
        BreadcrumbItem(label: 'New Sale'),
      ];
    }
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
      label: _getPlaceName(context, placeId),
      route: path.contains('/area/') ? Routes.place(day, placeId) : null
    ));
  }

  if (path.contains('/area/')) {
    final areaId = params['areaId'] ?? '';
    final placeId = params['placeId'] ?? '';
    breadcrumbs.add(BreadcrumbItem(
      label: _getAreaName(context, areaId),
      route: path.contains('/customer/') ? Routes.area(day, placeId, areaId) : null
    ));
  }

  if (path.contains('/customer/')) {
    final source = state.uri.queryParameters['source'];
    if (source == 'transactions') {
      return [
        BreadcrumbItem(label: 'Dashboard', route: Routes.dashboard),
        BreadcrumbItem(label: 'Transactions', route: '/transactions'),
        BreadcrumbItem(label: _getCustomerName(context, params['customerId'] ?? '')),
      ];
    } else if (source == 'clients') {
      return [
        BreadcrumbItem(label: 'Dashboard', route: Routes.dashboard),
        BreadcrumbItem(label: 'Clients', route: '/profile'),
        BreadcrumbItem(label: _getCustomerName(context, params['customerId'] ?? '')),
      ];
    }
    final customerId = params['customerId'] ?? '';
    breadcrumbs.add(BreadcrumbItem(
      label: _getCustomerName(context, customerId),
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
    final source = state.uri.queryParameters['source'];
    final suffix = source != null ? '?source=$source' : '';
    final customerRoute = Routes.customer(
      params['day'] ?? 'Monday',
      params['placeId'] ?? '',
      params['areaId'] ?? '',
      params['customerId'] ?? '',
    );
    return '$customerRoute$suffix';
  }
  if (path.contains('/customer/')) {
    final source = state.uri.queryParameters['source'];
    if (source == 'transactions') {
      return '/transactions';
    } else if (source == 'clients') {
      return '/profile';
    }
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

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key, required this.child});

  final Widget child;

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  bool _isBottomNavVisible = true;
  int _lastSelectedIndex = 0;

  bool _isDashboard(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return location == Routes.dashboard;
  }

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
    final backTarget = context.getBackTarget();
    final isDashboard = _isDashboard(context);

    // Dynamically adjust system navigation bar overlay transparency globally
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Theme.of(context).brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
      statusBarBrightness: Theme.of(context).brightness,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Theme.of(context).brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
      systemNavigationBarContrastEnforced: false,
    ));

    // Ensure bottom nav is always visible on non-dashboard screens
    if (!isDashboard) {
      _isBottomNavVisible = true;
    }

    // Reset visibility if the tab selection changes
    if (selectedIndex != _lastSelectedIndex) {
      _lastSelectedIndex = selectedIndex;
      _isBottomNavVisible = true;
    }

    final scaffold = Scaffold(
      extendBody: showBottomNav, // Extend body behind bottom nav bar on all nav screens
      body: showBottomNav
          ? MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: widget.child,
            )
          : widget.child,
      bottomNavigationBar: showBottomNav
          ? AnimatedSlide(
              offset: _isBottomNavVisible ? Offset.zero : const Offset(0, 2.0),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              child: FloatingBottomNav(
                selectedIndex: selectedIndex,
                onTap: (index) => _onBottomNavTapped(context, index),
              ),
            )
          : null,
    );

    final wrappedWithPop = backTarget != null
        ? PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.go(backTarget);
                }
              });
            },
            child: scaffold,
          )
        : scaffold;

    final systemOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Theme.of(context).brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
      statusBarBrightness: Theme.of(context).brightness,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Theme.of(context).brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
      systemNavigationBarContrastEnforced: false,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlayStyle,
      child: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          // Only trigger scroll-to-hide on the Dashboard screen
          if (_isDashboard(context)) {
            if (notification.direction == ScrollDirection.reverse) {
              if (_isBottomNavVisible) {
                setState(() {
                  _isBottomNavVisible = false;
                });
              }
            } else if (notification.direction == ScrollDirection.forward) {
              if (!_isBottomNavVisible) {
                setState(() {
                  _isBottomNavVisible = true;
                });
              }
            }
          }
          return false; // Bubbles scroll notification to let other listeners react
        },
        child: wrappedWithPop,
      ),
    );
  }
}

// Extension for easier breadcrumb and back-nav computation
extension NavigationExtension on BuildContext {
  List<BreadcrumbItem> getBreadcrumbs() {
    return _buildBreadcrumbs(this, GoRouterState.of(this));
  }

  String? getBackTarget() {
    return _computeBackTarget(GoRouterState.of(this));
  }
}
