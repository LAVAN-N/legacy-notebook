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
import '../models/location.dart';
import '../models/nominee.dart';
import '../models/id_proof.dart';
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
    _places = List.from(mockPlacesList);
    _areas = List.from(mockAreasList);
    _syncController();
  }

  final Ref _ref;

  late List<Customer> _customers;
  late List<Sale> _sales;
  late List<Collection> _collections;
  late List<Product> _products;
  late List<Place> _places;
  late List<Area> _areas;

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
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      final old = _customers[index];
      final newNominee = Nominee(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        phone: phone,
        relation: relation,
      );
      _customers[index] = old.copyWith(
        nominees: [...old.nominees, newNominee],
      );
      _syncController();
    }
  }

  @override
  Future<void> addProofImage(String customerId, String proofType, String imageUrl) async {
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      final old = _customers[index];
      final newProof = IdProof(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: proofType,
        number: 'DOC-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        document: IdProofDocument(
          filename: imageUrl.split('/').last,
          mimeType: imageUrl.endsWith('.pdf') ? 'application/pdf' : 'image/jpeg',
          sizeBytes: 1024 * 500,
          localUri: imageUrl,
        ),
      );
      _customers[index] = old.copyWith(
        idProofs: [...old.idProofs, newProof],
      );
      _syncController();
    }
  }

  /// Add a new customer to the repository.
  /// If [openingBalance] > 0, creates a synthetic SALE row with [kind=SALE, saleType=CREDIT, total=opening, advance=0, creditAdded=opening].
  /// Returns the new customer with generated [id].
  @override
  Future<Customer> addCustomer({
    required String name,
    required String phone,
    required String address,
    required String weekdayId,
    required String placeId,
    required String areaId,
    String? alternatePhone,
    String? landmark,
    String? notes,
    int openingBalance = 0,
    List<Nominee>? nominees,
    List<IdProof>? idProofs,
    Location? location,
  }) async {
    // Generate UUID-like ID
    final customerId = 'c-${DateTime.now().millisecondsSinceEpoch}-${_customers.length + 1}';
    
    // Generate unique customer code
    final nextCode = _customers.length + 1;
    final customerCode = 'C-${nextCode.toString().padLeft(3, '0')}';
    
    // Get the highest sequence number for this area
    final areaCustomers = _customers.where((c) => c.areaId == areaId).toList();
    final maxSeq = areaCustomers.isEmpty ? 0 : areaCustomers.map((c) => c.sequenceNumber).reduce((a, b) => a > b ? a : b);

    final newCustomer = Customer(
      id: customerId,
      customerCode: customerCode,
      name: name,
      phone: phone,
      alternatePhone: alternatePhone,
      address: address,
      landmark: landmark,
      weekdayId: weekdayId,
      placeId: placeId,
      areaId: areaId,
      sequenceNumber: maxSeq + 1,
      status: 'ACTIVE',
      notes: notes,
      nominees: nominees ?? const [],
      idProofs: idProofs ?? const [],
      location: location,
    );

    _customers.add(newCustomer);

    // If opening balance > 0, create synthetic SALE
    if (openingBalance > 0) {
      final syntheticSale = Sale(
        id: 's-opening-${DateTime.now().millisecondsSinceEpoch}',
        customerId: customerId,
        saleDatetime: DateTime.now(),
        saleType: 'CREDIT',
        totalAmount: openingBalance,
        advanceAmount: 0,
        financedAmount: openingBalance,
        soldBy: 'System',
        remarks: 'Opening balance',
      );
      _sales.add(syntheticSale);
    }

    _ref.read(syncProvider.notifier).incrementPending();
    AppHaptics.mediumImpact();
    _syncController();

    return newCustomer;
  }

  @override
  Future<void> undoCustomer(String customerId) async {
    _customers.removeWhere((c) => c.id == customerId);
    // Also remove any opening balance sale
    _sales.removeWhere((s) => s.customerId == customerId && s.remarks == 'Opening balance');
    _syncController();
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      _customers[index] = customer;
      _syncController();
    }
  }

  @override
  Future<Place> addPlace({
    required String weekdayId,
    required String name,
  }) async {
    final placeId = 'p-${DateTime.now().millisecondsSinceEpoch}';
    
    final newPlace = Place(
      id: placeId,
      weekdayId: weekdayId,
      name: name,
    );

    _places.add(newPlace);
    _syncController();

    return newPlace;
  }

  @override
  Future<Area> addArea({
    required String placeId,
    required String name,
  }) async {
    final areaId = 'a-${DateTime.now().millisecondsSinceEpoch}';
    
    final newArea = Area(
      id: areaId,
      placeId: placeId,
      name: name,
    );

    _areas.add(newArea);
    _syncController();

    return newArea;
  }

  // ─── RouteRepository ────────────────────────────────────

  @override
  Future<List<Weekday>> getWeekdays() async => mockWeekdaysList;

  @override
  Stream<List<Weekday>> watchWeekdays() => Stream.value(mockWeekdaysList);

  @override
  Future<List<Place>> getPlacesByWeekday(String weekdayId) async {
    return _places.where((p) => p.weekdayId == weekdayId).toList();
  }

  @override
  Stream<List<Place>> watchPlacesByWeekday(String weekdayId) {
    return _updateController.stream.map((_) {
      return _places.where((p) => p.weekdayId == weekdayId).toList();
    });
  }

  @override
  Future<List<Area>> getAreasByPlace(String placeId) async {
    return _areas.where((a) => a.placeId == placeId).toList();
  }

  @override
  Stream<List<Area>> watchAreasByPlace(String placeId) {
    return _updateController.stream.map((_) {
      return _areas.where((a) => a.placeId == placeId).toList();
    });
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
