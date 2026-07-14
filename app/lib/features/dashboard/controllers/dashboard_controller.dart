import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/activity.dart';
import '../../../data/models/place.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/route_repository.dart';
import '../../../data/providers.dart';

class DashboardData {
  const DashboardData({
    required this.weekdayName,
    required this.placeCount,
    required this.areaCount,
    required this.customerCount,
    required this.expectedAmount,
    required this.collectedAmount,
    required this.pendingVisitsCount,
    required this.totalOutstanding,
    required this.recentActivities,
    required this.todayPlaces,
  });

  final String weekdayName;
  final int placeCount;
  final int areaCount;
  final int customerCount;
  final int expectedAmount;
  final int collectedAmount;
  final int pendingVisitsCount;
  final int totalOutstanding;
  final List<Activity> recentActivities;
  final List<Place> todayPlaces;
}

final dashboardControllerProvider = StateNotifierProvider<DashboardController, AsyncValue<DashboardData>>((ref) {
  return DashboardController(ref);
});

class DashboardController extends StateNotifier<AsyncValue<DashboardData>> {
  DashboardController(this._ref) : super(const AsyncValue.loading()) {
    print('[DashboardController] Initializing...');
    _init();
  }

  final Ref _ref;

  void _init() async {
    print('[DashboardController] _init() called');
    _ref.listenSelf((previous, next) {}); // Keep listening for changes
    await refresh();
    print('[DashboardController] _init() completed');
  }

  Future<void> refresh() async {
    print('[DashboardController] refresh() started');
    state = const AsyncValue.loading();
    try {
      final routeRepo = _ref.read(routeRepositoryProvider);
      final customerRepo = _ref.read(customerRepositoryProvider);

      // We'll seed Melur and Thursday as "today" for demonstration consistency
      final weekdayId = 'w-4'; // Thursday
      final weekdayName = 'Thursday';

      final places = await routeRepo.getPlacesByWeekday(weekdayId);
      int areaCount = 0;
      for (final p in places) {
        final areas = await routeRepo.getAreasByPlace(p.id);
        areaCount += areas.length;
      }

      final customerCount = await routeRepo.getCustomerCountForWeekday(weekdayId);
      final expected = await routeRepo.getExpectedCollectionForWeekday(weekdayId);
      final collected = await routeRepo.getActualCollectionForWeekday(weekdayId);

      // Compute pending visits: visits with CARRY_FORWARD, PAYMENT or PARTIAL_PAYMENT today.
      // We will fetch all customers on this route first.
      int pending = customerCount;
      final placesInWeekday = await routeRepo.getPlacesByWeekday(weekdayId);
      for (final p in placesInWeekday) {
        final areas = await routeRepo.getAreasByPlace(p.id);
        for (final a in areas) {
          final customers = await customerRepo.getCustomersByArea(a.id);
          for (final c in customers) {
            final todayCol = await _ref.read(collectionRepositoryProvider).getCollectionsForCustomerToday(c.id);
            if (todayCol.isNotEmpty) {
              pending--;
            }
          }
        }
      }

      // Compute total business outstanding
      int totalOutstanding = 0;
      
      // Let's sum all outstanding across all mock customers
      final allCustomers = [
        'c-1', 'c-2', 'c-3', 'c-4', 'c-5', 'c-6', 'c-7', 'c-8'
      ];
      for (final cid in allCustomers) {
        final out = await customerRepo.getCustomerOutstanding(cid);
        totalOutstanding += out.outstandingAmount;
      }

      // Recent activities: we can get the timeline of main customers and sort
      final List<Activity> recent = [];
      for (final cid in ['c-1', 'c-2', 'c-3', 'c-6']) {
        final timeline = await customerRepo.getCustomerTimeline(cid);
        recent.addAll(timeline);
      }
      recent.sort((a, b) => b.at.compareTo(a.at));
      final trimmedRecent = recent.take(5).toList();

      state = AsyncValue.data(DashboardData(
        weekdayName: weekdayName,
        placeCount: places.length,
        areaCount: areaCount,
        customerCount: customerCount,
        expectedAmount: expected,
        collectedAmount: collected,
        pendingVisitsCount: pending < 0 ? 0 : pending,
        totalOutstanding: totalOutstanding,
        recentActivities: trimmedRecent,
        todayPlaces: places,
      ));
      print('[DashboardController] refresh() completed with data');
    } catch (e, stack) {
      print('[DashboardController] refresh() ERROR: $e');
      print('[DashboardController] Stack: $stack');
      state = AsyncValue.error(e, stack);
    }
  }
}
