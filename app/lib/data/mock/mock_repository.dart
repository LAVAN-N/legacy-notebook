import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/sync_status_indicator.dart';
import '../models/customer.dart';
import '../models/outstanding.dart';
import '../models/activity.dart';
import '../models/weekday.dart';
import '../models/place.dart';
import '../models/area.dart';
import '../models/collection.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../repositories/customer_repository.dart';
import '../repositories/route_repository.dart';
import '../repositories/collection_repository.dart';
import '../repositories/sale_repository.dart';
import '../repositories/product_repository.dart';
import 'mock_data.dart';

class MockRepository implements CustomerRepository, RouteRepository, CollectionRepository, SaleRepository, ProductRepository {
  MockRepository(this._ref) {
    _customers = List.from(mockCustomersList);
    _sales = List.from(mockSalesList);
    _collections = List.from(mockCollectionsList);
    _products = List.from(mockProductsList);
    _syncController();
  }

  final Ref _ref;

  late List<Customer> _customers;
  late List<Sale> _sales;
  late List<Collection> _collections;
  late List<Product> _products;

  final _updateController = StreamController<void>.broadcast();

  void _syncController() {
    _updateController.add(null);
  }

  // ─── CustomerRepository ─────────────────────────────────

  @override
  Stream<List<Customer>> watchCustomersByArea(String areaId) {
    return _updateController.stream.map((_) {
      return _customers.where((c) => c.areaId == areaId).toList()
        ..sort((a, b) => a.sequenceNumber.compareTo(b.sequenceNumber));
    });
  }

  @override
  Future<List<Customer>> getCustomersByArea(String areaId) async {
    return _customers.where((c) => c.areaId == areaId).toList()
      ..sort((a, b) => a.sequenceNumber.compareTo(b.sequenceNumber));
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<Customer?> watchCustomerById(String id) {
    return _updateController.stream.map((_) {
      try {
        return _customers.firstWhere((c) => c.id == id);
      } catch (_) {
        return null;
      }
    });
  }

  @override
  Stream<Outstanding> watchCustomerOutstanding(String customerId) {
    return _updateController.stream.map((_) {
      return _calculateOutstanding(customerId);
    });
  }

  @override
  Future<Outstanding> getCustomerOutstanding(String customerId) async {
    return _calculateOutstanding(customerId);
  }

  Outstanding _calculateOutstanding(String customerId) {
    final customerSales = _sales.where((s) => s.customerId == customerId);
    final customerCollections = _collections.where((c) =>
        c.customerId == customerId &&
        (c.status == 'PAYMENT' || c.status == 'PARTIAL_PAYMENT'));

    final totalFinanced = customerSales.fold<int>(0, (sum, s) => sum + s.financedAmount);
    final totalCollected = customerCollections.fold<int>(0, (sum, c) => sum + c.amount);

    return Outstanding(
      customerId: customerId,
      totalFinanced: totalFinanced,
      totalCollected: totalCollected,
      outstandingAmount: totalFinanced - totalCollected,
    );
  }

  @override
  Stream<List<Activity>> watchCustomerTimeline(String customerId) {
    return _updateController.stream.map((_) => _buildTimeline(customerId));
  }

  @override
  Future<List<Activity>> getCustomerTimeline(String customerId) async {
    return _buildTimeline(customerId);
  }

  List<Activity> _buildTimeline(String customerId) {
    final List<Activity> activities = [];

    // Port collections
    for (final col in _collections.where((c) => c.customerId == customerId)) {
      if (col.status == 'PAYMENT') {
        activities.add(Activity.payment(
          id: col.id,
          at: col.visitDatetime,
          amount: col.amount,
          note: col.reason,
          collectorName: col.collectedBy,
        ));
      } else if (col.status == 'PARTIAL_PAYMENT') {
        activities.add(Activity.partialPayment(
          id: col.id,
          at: col.visitDatetime,
          amount: col.amount,
          note: col.reason ?? '',
          collectorName: col.collectedBy,
        ));
      } else if (col.status == 'CARRY_FORWARD') {
        activities.add(Activity.carryForward(
          id: col.id,
          at: col.visitDatetime,
          note: col.reason ?? '',
          collectorName: col.collectedBy,
        ));
      }
    }

    // Port sales
    for (final s in _sales.where((s) => s.customerId == customerId)) {
      activities.add(Activity.sale(
        id: s.id,
        at: s.saleDatetime,
        items: [
          // Mocking items on the fly for UI simplicity
          SaleItemDetail(
            productName: s.totalAmount == 16500
                ? 'LG 190L Single Door Refrigerator'
                : s.totalAmount == 3200
                    ? 'Prestige Mixer Grinder 3 Jar'
                    : s.totalAmount == 2800
                        ? 'Philips Induction Cooktop HD4928'
                        : s.totalAmount == 28500
                            ? 'IFB 7Kg Front Load Washing Machine'
                            : 'Usha Dry Iron 1000W',
            quantity: 1,
            unitPrice: s.totalAmount,
          ),
        ],
        total: s.totalAmount,
        advance: s.advanceAmount,
        creditAdded: s.financedAmount,
        saleType: s.saleType,
        collectorName: s.soldBy,
        note: s.remarks,
      ));
    }

    activities.sort((a, b) => b.at.compareTo(a.at));
    return activities;
  }

  @override
  Future<void> updateCustomerProfile(String id, {String? phone, String? photoUrl, String? locationUrl}) async {
    final index = _customers.indexWhere((c) => c.id == id);
    if (index != -1) {
      final old = _customers[index];
      _customers[index] = old.copyWith(
        phone: phone ?? old.phone,
        photoUrl: photoUrl ?? old.photoUrl,
        locationUrl: locationUrl ?? old.locationUrl,
      );
      _syncController();
    }
  }

  @override
  Future<void> addNominee(String customerId, String name, String phone, String relation) async {
    // Nominees stored inside mock customer profile json/notes in memory
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      final old = _customers[index];
      final newNotes = '${old.notes ?? ''}\nNominee: $name ($relation, $phone)';
      _customers[index] = old.copyWith(notes: newNotes);
      _syncController();
    }
  }

  @override
  Future<void> addProofImage(String customerId, String proofType, String imageUrl) async {
    // Proof images stored inside mock customer profile json/notes in memory
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      final old = _customers[index];
      final newNotes = '${old.notes ?? ''}\nProof: $proofType ($imageUrl)';
      _customers[index] = old.copyWith(notes: newNotes);
      _syncController();
    }
  }

  // ─── RouteRepository ────────────────────────────────────

  @override
  Future<List<Weekday>> getWeekdays() async => mockWeekdaysList;

  @override
  Stream<List<Weekday>> watchWeekdays() => Stream.value(mockWeekdaysList);

  @override
  Future<List<Place>> getPlacesByWeekday(String weekdayId) async {
    return mockPlacesList.where((p) => p.weekdayId == weekdayId).toList();
  }

  @override
  Stream<List<Place>> watchPlacesByWeekday(String weekdayId) {
    return Stream.value(mockPlacesList.where((p) => p.weekdayId == weekdayId).toList());
  }

  @override
  Future<List<Area>> getAreasByPlace(String placeId) async {
    return mockAreasList.where((a) => a.placeId == placeId).toList();
  }

  @override
  Stream<List<Area>> watchAreasByPlace(String placeId) {
    return Stream.value(mockAreasList.where((a) => a.placeId == placeId).toList());
  }

  @override
  Future<int> getCustomerCountForWeekday(String weekdayId) async {
    return _customers.where((c) => c.weekdayId == weekdayId).length;
  }

  @override
  Future<int> getCustomerCountForPlace(String placeId) async {
    return _customers.where((c) => c.placeId == placeId).length;
  }

  @override
  Future<int> getCustomerCountForArea(String areaId) async {
    return _customers.where((c) => c.areaId == areaId).length;
  }

  @override
  Future<int> getExpectedCollectionForWeekday(String weekdayId) async {
    final customers = _customers.where((c) => c.weekdayId == weekdayId);
    int sum = 0;
    for (final c in customers) {
      final outstanding = await getCustomerOutstanding(c.id);
      sum += outstanding.outstandingAmount;
    }
    return sum;
  }

  @override
  Future<int> getExpectedCollectionForPlace(String placeId) async {
    final customers = _customers.where((c) => c.placeId == placeId);
    int sum = 0;
    for (final c in customers) {
      final outstanding = await getCustomerOutstanding(c.id);
      sum += outstanding.outstandingAmount;
    }
    return sum;
  }

  @override
  Future<int> getExpectedCollectionForArea(String areaId) async {
    final customers = _customers.where((c) => c.areaId == areaId);
    int sum = 0;
    for (final c in customers) {
      final outstanding = await getCustomerOutstanding(c.id);
      sum += outstanding.outstandingAmount;
    }
    return sum;
  }

  @override
  Future<int> getActualCollectionForWeekday(String weekdayId) async {
    final customers = _customers.where((c) => c.weekdayId == weekdayId).map((c) => c.id).toSet();
    final todayCollections = _collections.where((col) =>
        customers.contains(col.customerId) &&
        (col.status == 'PAYMENT' || col.status == 'PARTIAL_PAYMENT'));
    return todayCollections.fold<int>(0, (sum, c) => sum + c.amount);
  }

  @override
  Future<int> getActualCollectionForPlace(String placeId) async {
    final customers = _customers.where((c) => c.placeId == placeId).map((c) => c.id).toSet();
    final todayCollections = _collections.where((col) =>
        customers.contains(col.customerId) &&
        (col.status == 'PAYMENT' || col.status == 'PARTIAL_PAYMENT'));
    return todayCollections.fold<int>(0, (sum, c) => sum + c.amount);
  }

  @override
  Future<int> getActualCollectionForArea(String areaId) async {
    final customers = _customers.where((c) => c.areaId == areaId).map((c) => c.id).toSet();
    final todayCollections = _collections.where((col) =>
        customers.contains(col.customerId) &&
        (col.status == 'PAYMENT' || col.status == 'PARTIAL_PAYMENT'));
    return todayCollections.fold<int>(0, (sum, c) => sum + c.amount);
  }

  // ─── CollectionRepository ───────────────────────────────

  @override
  Stream<List<Collection>> watchCollectionsForCustomerToday(String customerId) {
    return _updateController.stream.map((_) {
      return _collections.where((col) =>
          col.customerId == customerId &&
          col.visitDatetime.day == DateTime.now().day &&
          col.visitDatetime.month == DateTime.now().month &&
          col.visitDatetime.year == DateTime.now().year).toList();
    });
  }

  @override
  Future<List<Collection>> getCollectionsForCustomerToday(String customerId) async {
    return _collections.where((col) =>
        col.customerId == customerId &&
        col.visitDatetime.day == DateTime.now().day &&
        col.visitDatetime.month == DateTime.now().month &&
        col.visitDatetime.year == DateTime.now().year).toList();
  }

  @override
  Future<void> saveCollection({
    required String customerId,
    required String status,
    required int amount,
    String? reason,
    required String collectedBy,
  }) async {
    final collection = Collection(
      id: 'col-${DateTime.now().millisecondsSinceEpoch}',
      customerId: customerId,
      visitDatetime: DateTime.now(),
      status: status,
      amount: amount,
      reason: reason,
      collectedBy: collectedBy,
    );

    _collections.add(collection);
    _ref.read(syncProvider.notifier).incrementPending();
    AppHaptics.mediumImpact();
    _syncController();
  }

  @override
  Future<void> undoCollection(String collectionId) async {
    _collections.removeWhere((c) => c.id == collectionId);
    _syncController();
  }

  // ─── SaleRepository ─────────────────────────────────────

  @override
  Future<void> saveSale({
    required String customerId,
    required List<Map<String, dynamic>> items,
    required int advanceAmount,
    required String soldBy,
    String? remarks,
  }) async {
    int total = 0;
    for (final item in items) {
      final qty = item['quantity'] as int;
      final price = item['unitPrice'] as int;
      total += qty * price;

      // Atomic inventory deduction
      final pIndex = _products.indexWhere((p) => p.id == item['productId']);
      if (pIndex != -1) {
        final p = _products[pIndex];
        _products[pIndex] = p.copyWith(stock: p.stock - qty);
      }
    }

    final creditAdded = total - advanceAmount;

    final sale = Sale(
      id: 's-${DateTime.now().millisecondsSinceEpoch}',
      customerId: customerId,
      saleDatetime: DateTime.now(),
      saleType: creditAdded == 0 ? 'READY' : 'CREDIT',
      totalAmount: total,
      advanceAmount: advanceAmount,
      financedAmount: creditAdded,
      soldBy: soldBy,
      remarks: remarks,
    );

    _sales.add(sale);
    _ref.read(syncProvider.notifier).incrementPending();
    AppHaptics.mediumImpact();
    _syncController();
  }

  @override
  Future<void> undoSale(String saleId) async {
    _sales.removeWhere((s) => s.id == saleId);
    _syncController();
  }

  // ─── ProductRepository ──────────────────────────────────

  @override
  Future<List<Product>> getProducts() async => _products;

  @override
  Stream<List<Product>> watchProducts() {
    return _updateController.stream.map((_) => _products);
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

// Global Providers to bind the abstract interfaces

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return ref.watch(mockRepositoryProvider);
});

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return ref.watch(mockRepositoryProvider);
});

final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  return ref.watch(mockRepositoryProvider);
});

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return ref.watch(mockRepositoryProvider);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ref.watch(mockRepositoryProvider);
});

final mockRepositoryProvider = Provider<MockRepository>((ref) {
  return MockRepository(ref);
});
