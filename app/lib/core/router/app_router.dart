import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';
import '../../data/models/customer.dart';


// Import Screens
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/route/weekday_screen.dart';
import '../../features/route/place_screen.dart';
import '../../features/route/area_screen.dart';
import '../../features/customer/customer_detail_screen.dart';
import '../../features/customer/clients_screen.dart';
import '../../features/customer/new_client_screen.dart';
import '../../features/collection/collect_screen.dart';
import '../../features/sale/sale_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/splash/splash_controller.dart';
import '../../features/transactions/transactions_screen.dart';
import '../../features/inventory/inventory_categories_screen.dart';
import '../../features/inventory/inventory_products_screen.dart';
import 'navigation_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ValueNotifier<bool>(true);
  
  ref.listen<SplashState>(splashControllerProvider, (previous, next) {
    refreshListenable.value = next.isSplashVisible;
  });

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final splashVisible = ref.read(splashControllerProvider).isSplashVisible;
      
      if (state.matchedLocation == Routes.splash && !splashVisible) {
        return Routes.dashboard;
      }
      if (state.matchedLocation != Routes.splash && splashVisible) {
        return Routes.splash;
      }
      return null;
    },
    routes: [
      // Splash screen (root overlay route)
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
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
            path: Routes.inventory,
            builder: (context, state) => const InventoryCategoriesScreen(),
          ),
          GoRoute(
            path: Routes.inventoryCategoryPattern,
            builder: (context, state) {
              final categoryId = state.pathParameters['categoryId'] ?? '';
              final productId = state.uri.queryParameters['productId'];
              return InventoryProductsScreen(
                categoryId: categoryId,
                initialProductId: productId,
              );
            },
          ),
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ClientsScreen(),
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
              final day = state.pathParameters['day'] ?? 'Monday';
              final placeId = state.pathParameters['placeId'] ?? '';
              return PlaceScreen(placeId: placeId, weekday: day);
            },
          ),
          GoRoute(
            path: Routes.areaPattern,
            builder: (context, state) {
              final day = state.pathParameters['day'] ?? 'Monday';
              final placeId = state.pathParameters['placeId'] ?? '';
              final areaId = state.pathParameters['areaId'] ?? '';
              return AreaScreen(areaId: areaId, placeId: placeId, weekday: day);
            },
          ),
          GoRoute(
            path: Routes.customerPattern,
            builder: (context, state) {
              final day = state.pathParameters['day'] ?? 'Monday';
              final placeId = state.pathParameters['placeId'] ?? '';
              final areaId = state.pathParameters['areaId'] ?? '';
              final customerId = state.pathParameters['customerId'] ?? '';
              return CustomerDetailScreen(
                customerId: customerId,
                weekday: day,
                placeId: placeId,
                areaId: areaId,
              );
            },
          ),
        ],
      ),
      // Leaf actions pushed onto the root navigator (sliding over the bottom bar/shell)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.newClient,
        builder: (context, state) {
          final customer = state.extra as Customer?;
          return NewClientScreen(customer: customer);
        },
      ),
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
});
