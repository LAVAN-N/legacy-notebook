import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/place.dart';
import '../../../data/models/area.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/outstanding.dart';
import '../../../data/models/sale.dart';
import '../../../data/models/collection.dart';
import '../../../data/providers.dart';

// Place with computed route status
class PlaceProgress {
  PlaceProgress({
    required this.place,
    required this.customerCount,
    required this.expectedAmount,
    required this.collectedAmount,
  });

  final Place place;
  final int customerCount;
  final int expectedAmount;
  final int collectedAmount;
}

final weekdayPlacesProvider = AsyncNotifierProvider.autoDispose.family<WeekdayPlacesNotifier, List<PlaceProgress>, String>((arg) {
  return WeekdayPlacesNotifier(arg);
});

class WeekdayPlacesNotifier extends AsyncNotifier<List<PlaceProgress>> {
  WeekdayPlacesNotifier(this.arg);
  final String arg;

  @override
  Future<List<PlaceProgress>> build() async {
    final routeRepo = ref.read(routeRepositoryProvider);
    final customerRepo = ref.read(customerRepositoryProvider);
    final saleRepo = ref.read(saleRepositoryProvider);
    final collectionRepo = ref.read(collectionRepositoryProvider);

    final weekday = await _findWeekdayByName(arg);
    if (weekday == null) return [];

    final results = await Future.wait([
      routeRepo.getPlacesByWeekday(weekday),
      customerRepo.getAllCustomers(),
      saleRepo.getAllSales(),
      collectionRepo.getAllCollections(),
    ]);

    final places = results[0] as List<Place>;
    final allCustomers = results[1] as List<Customer>;
    final allSales = results[2] as List<Sale>;
    final allCollections = results[3] as List<Collection>;

    final today = DateTime.now();

    // Map customers by place
    final Map<String, List<Customer>> customersByPlace = {};
    for (final c in allCustomers) {
      customersByPlace.putIfAbsent(c.placeId, () => []).add(c);
    }

    // Map sales by customer
    final Map<String, List<Sale>> salesByCustomer = {};
    for (final s in allSales) {
      salesByCustomer.putIfAbsent(s.customerId, () => []).add(s);
    }

    // Map collections by customer
    final Map<String, List<Collection>> collectionsByCustomer = {};
    for (final col in allCollections) {
      collectionsByCustomer.putIfAbsent(col.customerId, () => []).add(col);
    }

    final List<PlaceProgress> list = [];

    for (final p in places) {
      final placeCusts = customersByPlace[p.id] ?? [];
      int expected = 0;
      int collected = 0;

      for (final c in placeCusts) {
        final custSales = salesByCustomer[c.id] ?? [];
        final custCollections = collectionsByCustomer[c.id] ?? [];

        int financed = 0;
        for (final s in custSales) {
          financed += s.financedAmount;
        }

        int custTotalCollected = 0;
        for (final col in custCollections) {
          if (col.status == 'PAYMENT' || col.status == 'PARTIAL_PAYMENT') {
            custTotalCollected += col.amount.round();
          }
          if (col.visitDatetime.year == today.year &&
              col.visitDatetime.month == today.month &&
              col.visitDatetime.day == today.day &&
              (col.status == 'PAYMENT' || col.status == 'PARTIAL_PAYMENT')) {
            collected += col.amount.round();
          }
        }
        final outstanding = financed - custTotalCollected;
        if (outstanding > 0) {
          expected += outstanding;
        }
      }

      list.add(PlaceProgress(
        place: p,
        customerCount: placeCusts.length,
        expectedAmount: expected,
        collectedAmount: collected,
      ));
    }
    return list;
  }

  Future<String?> _findWeekdayByName(String name) async {
    final routeRepo = ref.read(routeRepositoryProvider);
    final days = await routeRepo.getWeekdays();
    try {
      return days.firstWhere((d) => d.name.toLowerCase() == name.toLowerCase()).id;
    } catch (_) {
      return null;
    }
  }
}

// Area with computed progress
class AreaProgress {
  AreaProgress({
    required this.area,
    required this.customerCount,
    required this.expectedAmount,
    required this.collectedAmount,
  });

  final Area area;
  final int customerCount;
  final int expectedAmount;
  final int collectedAmount;
}

final placeAreasProvider = AsyncNotifierProvider.autoDispose.family<PlaceAreasNotifier, List<AreaProgress>, String>((arg) {
  return PlaceAreasNotifier(arg);
});

class PlaceAreasNotifier extends AsyncNotifier<List<AreaProgress>> {
  PlaceAreasNotifier(this.arg);
  final String arg;

  @override
  Future<List<AreaProgress>> build() async {
    final routeRepo = ref.read(routeRepositoryProvider);
    final customerRepo = ref.read(customerRepositoryProvider);
    final saleRepo = ref.read(saleRepositoryProvider);
    final collectionRepo = ref.read(collectionRepositoryProvider);

    final results = await Future.wait([
      routeRepo.getAreasByPlace(arg),
      customerRepo.getAllCustomers(),
      saleRepo.getAllSales(),
      collectionRepo.getAllCollections(),
    ]);

    final areas = results[0] as List<Area>;
    final allCustomers = results[1] as List<Customer>;
    final allSales = results[2] as List<Sale>;
    final allCollections = results[3] as List<Collection>;

    final today = DateTime.now();

    // Map customers by area
    final Map<String, List<Customer>> customersByArea = {};
    for (final c in allCustomers) {
      if (c.placeId == arg) {
        customersByArea.putIfAbsent(c.areaId, () => []).add(c);
      }
    }

    // Map sales by customer
    final Map<String, List<Sale>> salesByCustomer = {};
    for (final s in allSales) {
      salesByCustomer.putIfAbsent(s.customerId, () => []).add(s);
    }

    // Map collections by customer
    final Map<String, List<Collection>> collectionsByCustomer = {};
    for (final col in allCollections) {
      collectionsByCustomer.putIfAbsent(col.customerId, () => []).add(col);
    }

    final List<AreaProgress> list = [];

    for (final a in areas) {
      final areaCusts = customersByArea[a.id] ?? [];
      int expected = 0;
      int collected = 0;

      for (final c in areaCusts) {
        final custSales = salesByCustomer[c.id] ?? [];
        final custCollections = collectionsByCustomer[c.id] ?? [];

        int financed = 0;
        for (final s in custSales) {
          financed += s.financedAmount;
        }

        int custTotalCollected = 0;
        for (final col in custCollections) {
          if (col.status == 'PAYMENT' || col.status == 'PARTIAL_PAYMENT') {
            custTotalCollected += col.amount.round();
          }
          if (col.visitDatetime.year == today.year &&
              col.visitDatetime.month == today.month &&
              col.visitDatetime.day == today.day &&
              (col.status == 'PAYMENT' || col.status == 'PARTIAL_PAYMENT')) {
            collected += col.amount.round();
          }
        }
        final outstanding = financed - custTotalCollected;
        if (outstanding > 0) {
          expected += outstanding;
        }
      }

      list.add(AreaProgress(
        area: a,
        customerCount: areaCusts.length,
        expectedAmount: expected,
        collectedAmount: collected,
      ));
    }
    return list;
  }
}

// Customer details list within an Area with outstanding balances
class CustomerProgress {
  CustomerProgress({
    required this.customer,
    required this.outstanding,
    required this.isVisitedToday,
    required this.lastCollectionStatus,
  });

  final Customer customer;
  final Outstanding outstanding;
  final bool isVisitedToday;
  final String? lastCollectionStatus;
}

final areaCustomersProvider = AsyncNotifierProvider.autoDispose.family<AreaCustomersNotifier, List<CustomerProgress>, String>((arg) {
  return AreaCustomersNotifier(arg);
});

class AreaCustomersNotifier extends AsyncNotifier<List<CustomerProgress>> {
  AreaCustomersNotifier(this.arg);
  final String arg;

  @override
  Future<List<CustomerProgress>> build() async {
    final customerRepo = ref.read(customerRepositoryProvider);
    final saleRepo = ref.read(saleRepositoryProvider);
    final collectionRepo = ref.read(collectionRepositoryProvider);

    final results = await Future.wait([
      customerRepo.getCustomersByArea(arg),
      saleRepo.getAllSales(),
      collectionRepo.getAllCollections(),
    ]);

    final customers = results[0] as List<Customer>;
    final allSales = results[1] as List<Sale>;
    final allCollections = results[2] as List<Collection>;

    final today = DateTime.now();

    // Map sales by customer
    final Map<String, List<Sale>> salesByCustomer = {};
    for (final s in allSales) {
      salesByCustomer.putIfAbsent(s.customerId, () => []).add(s);
    }

    // Map collections by customer
    final Map<String, List<Collection>> collectionsByCustomer = {};
    for (final col in allCollections) {
      collectionsByCustomer.putIfAbsent(col.customerId, () => []).add(col);
    }

    final List<CustomerProgress> list = [];

    for (final c in customers) {
      final custSales = salesByCustomer[c.id] ?? [];
      final custCollections = collectionsByCustomer[c.id] ?? [];

      int totalFinanced = 0;
      int totalLendFinanced = 0;
      int totalSaleFinanced = 0;

      for (final s in custSales) {
        final amount = s.financedAmount;
        final isLend = s.saleType.toUpperCase() == 'LEND' || (s.remarks != null && s.remarks!.startsWith('LEND_DETAILS:'));
        totalFinanced += amount;
        if (isLend) {
          totalLendFinanced += amount;
        } else {
          totalSaleFinanced += amount;
        }
      }

      int totalCollected = 0;
      int totalLendCollected = 0;
      int totalSaleCollected = 0;
      bool isVisitedToday = false;
      String? lastStatus;

      for (final col in custCollections) {
        final isPayment = col.status == 'PAYMENT' || col.status == 'PARTIAL_PAYMENT';
        if (isPayment) {
          final amount = col.amount.round();
          final isLend = col.reason != null && col.reason!.startsWith('COLLECTION_TARGET:target=LEND');
          totalCollected += amount;
          if (isLend) {
            totalLendCollected += amount;
          } else {
            totalSaleCollected += amount;
          }
        }

        if (col.visitDatetime.year == today.year &&
            col.visitDatetime.month == today.month &&
            col.visitDatetime.day == today.day) {
          isVisitedToday = true;
          lastStatus = col.status;
        }
      }

      final outstanding = Outstanding(
        customerId: c.id,
        totalFinanced: totalFinanced,
        totalCollected: totalCollected,
        outstandingAmount: totalFinanced - totalCollected,
        totalLendFinanced: totalLendFinanced,
        totalLendCollected: totalLendCollected,
        totalSaleFinanced: totalSaleFinanced,
        totalSaleCollected: totalSaleCollected,
      );

      list.add(CustomerProgress(
        customer: c,
        outstanding: outstanding,
        isVisitedToday: isVisitedToday,
        lastCollectionStatus: lastStatus,
      ));
    }

    // Sort by sequential customer ID
    list.sort((a, b) => (int.tryParse(a.customer.id) ?? 0).compareTo(int.tryParse(b.customer.id) ?? 0));
    return list;
  }

  Future<void> reorderSequence(List<CustomerProgress> newList) async {
    // Scaffold method for drag-and-drop sequencing
    state = AsyncValue.data(newList);
  }
}
