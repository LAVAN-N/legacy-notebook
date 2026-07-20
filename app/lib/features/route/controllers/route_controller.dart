import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/place.dart';
import '../../../data/models/area.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/outstanding.dart';
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

final weekdayPlacesProvider = AutoDisposeAsyncNotifierProviderFamily<WeekdayPlacesNotifier, List<PlaceProgress>, String>(() {
  return WeekdayPlacesNotifier();
});

class WeekdayPlacesNotifier extends AutoDisposeFamilyAsyncNotifier<List<PlaceProgress>, String> {
  @override
  Future<List<PlaceProgress>> build(String arg) async {
    final routeRepo = ref.read(routeRepositoryProvider);
    final weekday = await _findWeekdayByName(arg);
    if (weekday == null) return [];

    final places = await routeRepo.getPlacesByWeekday(weekday);
    final List<PlaceProgress> list = [];

    for (final p in places) {
      final customersCount = await routeRepo.getCustomerCountForPlace(p.id);
      final expected = await routeRepo.getExpectedCollectionForPlace(p.id);
      final collected = await routeRepo.getActualCollectionForPlace(p.id);

      list.add(PlaceProgress(
        place: p,
        customerCount: customersCount,
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

final placeAreasProvider = AutoDisposeAsyncNotifierProviderFamily<PlaceAreasNotifier, List<AreaProgress>, String>(() {
  return PlaceAreasNotifier();
});

class PlaceAreasNotifier extends AutoDisposeFamilyAsyncNotifier<List<AreaProgress>, String> {
  @override
  Future<List<AreaProgress>> build(String arg) async {
    final routeRepo = ref.read(routeRepositoryProvider);
    final areas = await routeRepo.getAreasByPlace(arg);
    final List<AreaProgress> list = [];

    for (final a in areas) {
      final customersCount = await routeRepo.getCustomerCountForArea(a.id);
      final expected = await routeRepo.getExpectedCollectionForArea(a.id);
      final collected = await routeRepo.getActualCollectionForArea(a.id);

      list.add(AreaProgress(
        area: a,
        customerCount: customersCount,
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

final areaCustomersProvider = AutoDisposeAsyncNotifierProviderFamily<AreaCustomersNotifier, List<CustomerProgress>, String>(() {
  return AreaCustomersNotifier();
});

class AreaCustomersNotifier extends AutoDisposeFamilyAsyncNotifier<List<CustomerProgress>, String> {
  @override
  Future<List<CustomerProgress>> build(String arg) async {
    final customerRepo = ref.read(customerRepositoryProvider);
    final collectionRepo = ref.read(collectionRepositoryProvider);

    final customers = await customerRepo.getCustomersByArea(arg);
    final List<CustomerProgress> list = [];

    for (final c in customers) {
      final outstanding = await customerRepo.getCustomerOutstanding(c.id);
      final collections = await collectionRepo.getCollectionsForCustomerToday(c.id);
      final isVisited = collections.isNotEmpty;
      final lastStatus = isVisited ? collections.last.status : null;

      list.add(CustomerProgress(
        customer: c,
        outstanding: outstanding,
        isVisitedToday: isVisited,
        lastCollectionStatus: lastStatus,
      ));
    }

    // Sort by sequence number
    list.sort((a, b) => a.customer.sequenceNumber.compareTo(b.customer.sequenceNumber));
    return list;
  }

  Future<void> reorderSequence(List<CustomerProgress> newList) async {
    // Scaffold method for drag-and-drop sequencing
    state = AsyncValue.data(newList);
  }
}
