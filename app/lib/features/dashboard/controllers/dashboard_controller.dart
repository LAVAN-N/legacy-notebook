import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../data/models/place.dart';
import '../../../data/models/area.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/sale.dart';
import '../../../data/models/collection.dart';
import '../../../data/providers.dart';
import '../../transactions/models/transaction_item.dart';

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
    required this.recentTransactions,
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
  final List<TransactionItem> recentTransactions;
  final List<Place> todayPlaces;
}

final dashboardControllerProvider = StateNotifierProvider<DashboardController, AsyncValue<DashboardData>>((ref) {
  return DashboardController(ref);
});

class DashboardController extends StateNotifier<AsyncValue<DashboardData>> {
  DashboardController(this._ref) : super(const AsyncValue.loading()) {
    developer.log('Initializing...', name: 'DashboardController');
    _init();
  }

  final Ref _ref;

  void _init() async {
    developer.log('_init() called', name: 'DashboardController');
    await refresh();
    developer.log('_init() completed', name: 'DashboardController');
  }

  Future<void> refresh() async {
    developer.log('refresh() started', name: 'DashboardController');
    state = const AsyncValue.loading();
    try {
      final routeRepo = _ref.read(routeRepositoryProvider);
      final customerRepo = _ref.read(customerRepositoryProvider);
      final saleRepo = _ref.read(saleRepositoryProvider);
      final collectionRepo = _ref.read(collectionRepositoryProvider);
      final configRepo = _ref.read(configRepositoryProvider);

      const weekdayId = 'w-4'; // Thursday
      const weekdayName = 'Thursday';

      // 1. Fetch all required data points concurrently in 8 parallel HTTP requests
      final batchResults = await Future.wait([
        routeRepo.getPlacesByWeekday(weekdayId),
        customerRepo.getAllCustomers(),
        saleRepo.getAllSales(),
        collectionRepo.getAllCollections(),
        configRepo.getAreas(),
        routeRepo.getCustomerCountForWeekday(weekdayId),
        routeRepo.getExpectedCollectionForWeekday(weekdayId),
        routeRepo.getActualCollectionForWeekday(weekdayId),
      ]);

      final places = batchResults[0] as List<Place>;
      final allCustomers = batchResults[1] as List<Customer>;
      final allSales = batchResults[2] as List<Sale>;
      final allCollections = batchResults[3] as List<Collection>;
      final allAreas = batchResults[4] as List<Area>;
      final customerCount = batchResults[5] as int;
      final expected = batchResults[6] as int;
      final collected = batchResults[7] as int;

      // 2. Count areas for places in-memory
      final placeIds = places.map((p) => p.id).toSet();
      final todayAreas = allAreas.where((a) => placeIds.contains(a.placeId)).toList();
      final areaCount = todayAreas.length;

      // 3. Compute pending visits in-memory
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      final visitedTodayCustomerIds = <String>{};
      for (final col in allCollections) {
        final colDate = col.visitDatetime.toIso8601String().split('T').first;
        if (colDate == todayStr) {
          visitedTodayCustomerIds.add(col.customerId);
        }
      }

      final todayAreaIds = todayAreas.map((a) => a.id).toSet();
      final routeCustomerIds = <String>{};
      for (final c in allCustomers) {
        if (todayAreaIds.contains(c.areaId)) {
          routeCustomerIds.add(c.id);
        }
      }

      int pending = routeCustomerIds.length;
      for (final cid in routeCustomerIds) {
        if (visitedTodayCustomerIds.contains(cid)) {
          pending--;
        }
      }

      // 4. Compute total business outstanding in-memory
      int totalFinanced = 0;
      for (final s in allSales) {
        totalFinanced += s.financedAmount;
      }

      int totalCollected = 0;
      for (final col in allCollections) {
        if (col.status == 'PAYMENT' || col.status == 'PARTIAL_PAYMENT') {
          totalCollected += col.amount.round();
        }
      }
      final totalOutstanding = totalFinanced - totalCollected;

      // 5. Build recent transactions timeline in-memory
      final List<TransactionItem> recent = [];

      String getCustomerName(String id) {
        final c = allCustomers.firstWhere(
          (c) => c.id == id,
          orElse: () => Customer(
            id: id,
            customerCode: 'Unknown',
            name: 'Unknown Client',
            phone: '',
            address: '',
            weekdayId: '',
            placeId: '',
            areaId: '',
            status: 'ACTIVE',
          ),
        );
        return c.name;
      }

      Customer? getCustomer(String id) {
        try {
          return allCustomers.firstWhere((c) => c.id == id);
        } catch (_) {
          return null;
        }
      }

      for (final s in allSales) {
        final isLend = s.saleType == 'LEND' || (s.remarks != null && s.remarks!.startsWith('LEND_DETAILS:'));
        final formattedRemarks = isLend
            ? LendDetails.parse(s.remarks ?? '').toSimpleInfo()
            : (s.remarks ?? '');

        recent.add(TransactionItem(
          id: s.id,
          customerId: s.customerId,
          customerName: getCustomerName(s.customerId),
          customer: getCustomer(s.customerId),
          date: s.saleDatetime,
          type: 'SALE',
          status: isLend ? 'LEND' : s.saleType,
          amount: s.totalAmount,
          subtitle: isLend
              ? 'Cash Loan / Lend'
              : (s.saleType == 'CREDIT'
                  ? 'Credit Sale · Financed ₹${s.financedAmount}'
                  : 'Ready Sale'),
          remarks: formattedRemarks,
        ));
      }

      for (final c in allCollections) {
        final col = CollectionDetails.parse(c.reason);
        final isLend = col.target == 'LEND';
        recent.add(TransactionItem(
          id: c.id,
          customerId: c.customerId,
          customerName: getCustomerName(c.customerId),
          customer: getCustomer(c.customerId),
          date: c.visitDatetime,
          type: 'COLLECTION',
          status: isLend ? 'LEND_COLLECTION' : c.status,
          amount: c.amount.round(),
          subtitle: isLend
              ? (c.status == 'PAYMENT'
                  ? 'Loan Repayment'
                  : (c.status == 'PARTIAL_PAYMENT'
                      ? 'Loan Partial Repayment'
                      : 'Loan Carry Forward'))
              : (c.status == 'PAYMENT'
                  ? 'Full Payment'
                  : (c.status == 'PARTIAL_PAYMENT'
                      ? 'Partial Payment'
                      : 'Carry Forward')),
          remarks: col.note,
        ));
      }

      recent.sort((a, b) => b.date.compareTo(a.date));
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
        recentTransactions: trimmedRecent,
        todayPlaces: places,
      ));
      developer.log('refresh() completed with data', name: 'DashboardController');
    } catch (e, stack) {
      developer.log('refresh() ERROR: $e', name: 'DashboardController', error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
    }
  }
}
