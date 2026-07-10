import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:legacy_notebook/features/auth/presentation/screens/splash_screen.dart';
import 'package:legacy_notebook/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:legacy_notebook/features/routes/presentation/screens/weekdays_screen.dart';
import 'package:legacy_notebook/features/routes/presentation/screens/places_screen.dart';
import 'package:legacy_notebook/features/routes/presentation/screens/areas_screen.dart';
import 'package:legacy_notebook/features/customers/presentation/screens/customers_screen.dart';
import 'package:legacy_notebook/features/customers/presentation/screens/customer_details_screen.dart';
import 'package:legacy_notebook/features/customers/presentation/screens/customer_search_screen.dart';
import 'routes/app_routes.dart';

/// GoRouter provider for dependency injection.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Route not found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.weekdays,
        builder: (context, state) => const WeekdaysScreen(),
      ),
      GoRoute(
        path: AppRoutes.places,
        builder: (context, state) {
          final weekdayId = state.pathParameters['weekdayId']!;
          return PlacesScreen(weekdayId: weekdayId);
        },
      ),
      GoRoute(
        path: AppRoutes.areas,
        builder: (context, state) {
          final weekdayId = state.pathParameters['weekdayId']!;
          final placeId = state.pathParameters['placeId']!;
          return AreasScreen(
            weekdayId: weekdayId,
            placeId: placeId,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.customers,
        builder: (context, state) {
          final weekdayId = state.pathParameters['weekdayId']!;
          final placeId = state.pathParameters['placeId']!;
          final areaId = state.pathParameters['areaId']!;
          return CustomersScreen(
            weekdayId: weekdayId,
            placeId: placeId,
            areaId: areaId,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.customerDetails,
        builder: (context, state) {
          final weekdayId = state.pathParameters['weekdayId']!;
          final placeId = state.pathParameters['placeId']!;
          final areaId = state.pathParameters['areaId']!;
          final customerId = state.pathParameters['customerId']!;
          return CustomerDetailsScreen(
            weekdayId: weekdayId,
            placeId: placeId,
            areaId: areaId,
            customerId: customerId,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const CustomerSearchScreen(),
      ),
    ],
  );
});
