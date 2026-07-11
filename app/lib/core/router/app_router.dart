import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';

// Import Screens (we will create these next)
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/route/weekday_screen.dart';
import '../../features/route/place_screen.dart';
import '../../features/route/area_screen.dart';
import '../../features/customer/customer_detail_screen.dart';
import '../../features/collection/collect_screen.dart';
import '../../features/sale/sale_screen.dart';
import 'navigation_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.dashboard,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return NavigationShell(child: child);
      },
      routes: [
        GoRoute(
          path: Routes.dashboard,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: Routes.weekdayPattern,
          builder: (context, state) {
            final day = state.pathParameters['day'] ?? 'Monday';
            return WeekdayScreen(dayName: day);
          },
        ),
        GoRoute(
          path: Routes.placePattern,
          builder: (context, state) {
            final placeId = state.pathParameters['placeId'] ?? '';
            return PlaceScreen(placeId: placeId);
          },
        ),
        GoRoute(
          path: Routes.areaPattern,
          builder: (context, state) {
            final areaId = state.pathParameters['areaId'] ?? '';
            return AreaScreen(areaId: areaId);
          },
        ),
        GoRoute(
          path: Routes.customerPattern,
          builder: (context, state) {
            final customerId = state.pathParameters['customerId'] ?? '';
            return CustomerDetailScreen(customerId: customerId);
          },
        ),
      ],
    ),
    // Leaf actions pushed onto the root navigator (sliding over the bottom bar/shell)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: Routes.collectPattern,
      builder: (context, state) {
        final customerId = state.pathParameters['customerId'] ?? '';
        return CollectScreen(customerId: customerId);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: Routes.salePattern,
      builder: (context, state) {
        final customerId = state.pathParameters['customerId'] ?? '';
        return SaleScreen(customerId: customerId);
      },
    ),
  ],
);
