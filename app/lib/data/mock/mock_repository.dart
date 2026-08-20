import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/sync_status_indicator.dart';
import '../../core/utils/uuid.dart';
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
    _saleItems = [];
    _syncController();
  }

  final Ref _ref;

  late List<Customer> _customers;
  late List<Sale> _sales;
  late List<Collection> _collections;
  late List<Product> _products;
  late List<Place> _places;
  late List<Area> _areas;
  late List<SaleItem> _saleItems;

  final _updateController = StreamController<void>.broadcast();

  void _syncController() {
    _updateController.add(null);
  }

  // ─── CustomerRepository ─────────────────────────────────

  @override
  Stream<List<Customer>> watchAllCustomers() async* {
    yield _customers;
    yield* _updateController.stream.map((_) => _customers);
  }

  @override
  Future<List<Customer>> getAllCustomers() async {
    return _customers;
  }

  @override
  Stream<List<Customer>> watchCustomersByArea(String areaId) async* {
    yield _customers.where((c) => c.areaId == areaId).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    yield* _updateController.stream.map((_) {
      return _customers.where((c) => c.areaId == areaId).toList()
        ..sort((a, b) => a.id.compareTo(b.id));
    });
  }

  @override
  Future<List<Customer>> getCustomersByArea(String areaId) async {
    return _customers.where((c) => c.areaId == areaId).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
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
  Stream<Customer?> watchCustomerById(String id) async* {
    try {
      yield _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      yield null;
    }
    yield* _updateController.stream.map((_) {
      try {
        return _customers.firstWhere((c) => c.id == id);
      } catch (_) {
        return null;
      }
    });
  }

  @override
  Stream<Outstanding> watchCustomerOutstanding(String customerId, {bool skipInitialFetch = false}) async* {
    if (!skipInitialFetch) yield _calculateOutstanding(customerId);
    yield* _updateController.stream.map((_) {
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
    final totalCollected = customerCollections.fold<int>(0, (sum, c) => sum + c.amount.round());

    final totalLendFinanced = customerSales
        .where((s) => s.saleType.toUpperCase() == 'LEND' || (s.remarks != null && s.remarks!.startsWith('LEND_DETAILS:')))
        .fold<int>(0, (sum, s) => sum + s.financedAmount);
    final totalSaleFinanced = customerSales
        .where((s) => s.saleType.toUpperCase() != 'LEND' && (s.remarks == null || !s.remarks!.startsWith('LEND_DETAILS:')))
        .fold<int>(0, (sum, s) => sum + s.financedAmount);

    final totalLendCollected = customerCollections
        .where((c) => c.reason != null && c.reason!.startsWith('COLLECTION_TARGET:target=LEND'))
        .fold<int>(0, (sum, c) => sum + c.amount.round());
    final totalSaleCollected = customerCollections
        .where((c) => c.reason == null || !c.reason!.startsWith('COLLECTION_TARGET:target=LEND'))
        .fold<int>(0, (sum, c) => sum + c.amount.round());

    return Outstanding(
      customerId: customerId,
      totalFinanced: totalFinanced,
      totalCollected: totalCollected,
      outstandingAmount: totalFinanced - totalCollected,
      totalLendFinanced: totalLendFinanced,
      totalLendCollected: totalLendCollected,
      totalSaleFinanced: totalSaleFinanced,
      totalSaleCollected: totalSaleCollected,
    );
  }

  @override
  Stream<List<Activity>> watchCustomerTimeline(String customerId, {bool skipInitialFetch = false}) async* {
    if (!skipInitialFetch) yield _buildTimeline(customerId);
    yield* _updateController.stream.map((_) => _buildTimeline(customerId));
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
          amount: col.amount.round(),
          note: col.reason,
          collectorName: col.collectedBy,
        ));
      } else if (col.status == 'PARTIAL_PAYMENT') {
        activities.add(Activity.partialPayment(
          id: col.id,
          at: col.visitDatetime,
          amount: col.amount.round(),
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
  Future<void> updateCustomerProfile(String id, {String? phone, String? profileUrl, String? locationUrl}) async {
    final index = _customers.indexWhere((c) => c.id == id);
    if (index != -1) {
      final old = _customers[index];
      _customers[index] = old.copyWith(
        phone: phone ?? old.phone,
        profileUrl: profileUrl ?? old.profileUrl,
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
        proofUrl: imageUrl,
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
    String? dob,
    String? occupation,
    int openingBalance = 0,
    List<Nominee>? nominees,
    List<IdProof>? idProofs,
    Location? location,
    String? profileUrl,
  }) async {
    int maxId = 0;
    for (final c in _customers) {
      final rawId = c.id;
      final numPart = rawId.replaceAll('CU-', '');
      final parsed = int.tryParse(numPart);
      if (parsed != null && parsed > maxId) {
        maxId = parsed;
      }
    }
    final nextIdNum = maxId + 1;
    final customerId = 'CU-${nextIdNum.toString().padLeft(3, '0')}';
    
    final wCode = weekdayId.replaceAll('w-', 'W').toUpperCase();
    final pCode = placeId.replaceAll('p-', 'P').toUpperCase();
    final aCode = areaId.replaceAll('a-', 'A').toUpperCase();
    final paddedId = nextIdNum.toString().padLeft(3, '0');
    final customerCode = '$wCode-$pCode-$aCode-$paddedId';

    final updatedNominees = (nominees ?? []).map((n) {
      return n.copyWith(
        id: n.id.isNotEmpty ? n.id : 'nom-uuid-${DateTime.now().microsecondsSinceEpoch}',
      );
    }).toList();

    final updatedProofs = (idProofs ?? []).map((p) {
      return p.copyWith(
        id: p.id.isNotEmpty ? p.id : 'proof-uuid-${DateTime.now().microsecondsSinceEpoch}',
      );
    }).toList();

    final newCustomer = Customer(
      id: customerId,
      customerCode: customerCode,
      name: name,
      phone: phone,
      alternatePhone: alternatePhone,
      address: address,
      landmark: landmark,
      profileUrl: profileUrl,
      weekdayId: weekdayId,
      placeId: placeId,
      areaId: areaId,
      status: 'ACTIVE',
      notes: notes,
      dob: dob,
      occupation: occupation,
      nominees: updatedNominees,
      idProofs: updatedProofs,
      location: location,
    );

    _customers.add(newCustomer);

    // If opening balance > 0, create synthetic SALE
    if (openingBalance > 0) {
      final syntheticSale = Sale(
        id: UuidUtils.generate(),
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
  Stream<List<Area>> watchAreasByPlace(String placeId) async* {
    yield _areas.where((a) => a.placeId == placeId).toList();
    yield* _updateController.stream.map((_) {
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
    return todayCollections.fold<int>(0, (sum, c) => sum + c.amount.round());
  }

  @override
  Future<int> getActualCollectionForPlace(String placeId) async {
    final customers = _customers.where((c) => c.placeId == placeId).map((c) => c.id).toSet();
    final todayCollections = _collections.where((col) =>
        customers.contains(col.customerId) &&
        (col.status == 'PAYMENT' || col.status == 'PARTIAL_PAYMENT'));
    return todayCollections.fold<int>(0, (sum, c) => sum + c.amount.round());
  }

  @override
  Future<int> getActualCollectionForArea(String areaId) async {
    final customers = _customers.where((c) => c.areaId == areaId).map((c) => c.id).toSet();
    final todayCollections = _collections.where((col) =>
        customers.contains(col.customerId) &&
        (col.status == 'PAYMENT' || col.status == 'PARTIAL_PAYMENT'));
    return todayCollections.fold<int>(0, (sum, c) => sum + c.amount.round());
  }

  // ─── CollectionRepository ───────────────────────────────

  @override
  Stream<List<Collection>> watchAllCollections() async* {
    yield _collections;
    yield* _updateController.stream.map((_) => _collections);
  }

  @override
  Future<List<Collection>> getAllCollections() async => _collections;

  @override
  Stream<List<Collection>> watchCollectionsForCustomerToday(String customerId) async* {
    yield _collections.where((col) =>
        col.customerId == customerId &&
        col.visitDatetime.day == DateTime.now().day &&
        col.visitDatetime.month == DateTime.now().month &&
        col.visitDatetime.year == DateTime.now().year).toList();
    yield* _updateController.stream.map((_) {
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
    required double amount,
    String? reason,
    required String collectedBy,
    DateTime? customDate,
    Map<String, int>? allocations,
  }) async {
    final adjustedAmount = (status == 'CARRY_FORWARD') ? 0.0 : amount;
    String finalReason = reason ?? '';

    finalReason = (allocations != null && allocations.isNotEmpty)
        ? '$finalReason&allocations=${jsonEncode(allocations)}'
        : finalReason;

    final collection = Collection(
      id: UuidUtils.generate(),
      customerId: customerId,
      visitDatetime: customDate ?? DateTime.now(),
      status: status,
      amount: adjustedAmount,
      reason: finalReason,
      collectedBy: collectedBy,
    );

    _collections.add(collection);

    if (allocations != null && allocations.isNotEmpty) {
      for (var entry in allocations.entries) {
        final index = _saleItems.indexWhere((si) => si.id == entry.key);
        if (index != -1) {
          final item = _saleItems[index];
          _saleItems[index] = item.copyWith(collectedAmount: item.collectedAmount + entry.value);
        }
      }
    }

    _ref.read(syncProvider.notifier).incrementPending();
    AppHaptics.mediumImpact();
    _syncController();
  }

  @override
  Future<void> undoCollection(String collectionId) async {
    final index = _collections.indexWhere((c) => c.id == collectionId);
    if (index != -1) {
      final col = _collections[index];
      final reason = col.reason;
      if (reason != null && reason.contains('&allocations=')) {
        try {
          final jsonStr = reason.split('&allocations=')[1];
          final allocations = Map<String, dynamic>.from(jsonDecode(jsonStr));
          for (var entry in allocations.entries) {
            final amount = (entry.value as num).toInt();
            final itemIndex = _saleItems.indexWhere((si) => si.id == entry.key);
            if (itemIndex != -1) {
              final item = _saleItems[itemIndex];
              _saleItems[itemIndex] = item.copyWith(
                collectedAmount: (item.collectedAmount - amount).clamp(0, 9999999),
              );
            }
          }
        } catch (_) {}
      }
      _collections.removeAt(index);
    }
    _syncController();
  }

  // ─── SaleRepository ─────────────────────────────────────

  @override
  Stream<List<Sale>> watchAllSales() async* {
    yield _sales;
    yield* _updateController.stream.map((_) => _sales);
  }

  @override
  Future<List<Sale>> getAllSales() async => _sales;

  @override
  Future<void> saveSale({
    required String customerId,
    required List<Map<String, dynamic>> items,
    required int advanceAmount,
    required String soldBy,
    int discount = 0,
    int creditCharge = 0,
    String? remarks,
    DateTime? customDate,
    int? lendAmount,
    int appliedCredit = 0,
  }) async {
    int total = 0;
    if (lendAmount != null) {
      total = lendAmount;
    } else {
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
    }
 
    final totalSaleAmount = total - discount + creditCharge;

    // Apply customer credit if available
    final customerIndex = _customers.indexWhere((c) => c.id == customerId);
    int creditUsed = 0;
    if (customerIndex != -1) {
      final cust = _customers[customerIndex];
      final currentCredit = cust.credit;
      creditUsed = appliedCredit.clamp(0, currentCredit < totalSaleAmount ? currentCredit : totalSaleAmount);
      if (creditUsed > 0) {
        _customers[customerIndex] = cust.copyWith(credit: currentCredit - creditUsed);
      }
    }

    final finalAdvanceAmount = advanceAmount + creditUsed;
    final finalFinancedAmount = totalSaleAmount - finalAdvanceAmount < 0 ? 0 : totalSaleAmount - finalAdvanceAmount;
    final finalSaleType = lendAmount != null ? 'LEND' : (finalFinancedAmount == 0 ? 'READY' : 'CREDIT');
 
    final sale = Sale(
      id: UuidUtils.generate(),
      customerId: customerId,
      saleDatetime: customDate ?? DateTime.now(),
      saleType: finalSaleType,
      totalAmount: totalSaleAmount,
      advanceAmount: finalAdvanceAmount,
      financedAmount: finalFinancedAmount,
      soldBy: soldBy,
      remarks: creditUsed > 0 
          ? '${remarks ?? ""}\n(Credit used: ₹$creditUsed)'.trim() 
          : remarks,
    );

    _sales.add(sale);

    // Save mock sale items
    if (lendAmount == null) {
      final int totalBaseAmount = items.fold<int>(0, (sum, i) => sum + ((i['quantity'] as int) * (i['unitPrice'] as int)));
      final int netAdjustment = creditCharge - discount;

      int remainingAdvance = finalAdvanceAmount;
      int adjustmentRemaining = netAdjustment;
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final qty = item['quantity'] as int;
        final baseUnitPrice = item['unitPrice'] as int;
        final baseItemTotal = qty * baseUnitPrice;

        final int itemAdjustment = (i == items.length - 1)
            ? adjustmentRemaining
            : (totalBaseAmount > 0 ? ((baseItemTotal * netAdjustment) / totalBaseAmount).round() : 0);
        adjustmentRemaining -= itemAdjustment;

        final itemTotal = baseItemTotal + itemAdjustment;
        final unitPrice = qty > 0 ? (itemTotal / qty).round() : itemTotal;

        final customAlloc = item['allocatedAmount'] as int?;
        final itemCollected = customAlloc != null
            ? customAlloc.clamp(0, itemTotal)
            : (remainingAdvance >= itemTotal ? itemTotal : remainingAdvance);
        if (customAlloc == null) {
          remainingAdvance -= itemCollected;
        }

        _saleItems.add(SaleItem(
          id: UuidUtils.generate(),
          saleId: sale.id,
          productId: item['productId'] as String,
          quantity: qty,
          unitPrice: unitPrice,
          totalPrice: itemTotal,
          status: 'purchased',
          collectedAmount: itemCollected,
        ));
      }
    }

    _ref.read(syncProvider.notifier).incrementPending();
    AppHaptics.mediumImpact();
    _syncController();
  }

  @override
  Future<void> undoSale(String saleId) async {
    _sales.removeWhere((s) => s.id == saleId);
    _saleItems.removeWhere((si) => si.saleId == saleId);
    _syncController();
  }

  @override
  Future<List<SaleItem>> getSaleItemsForCustomer(String customerId) async {
    final customerSalesList = _sales.where((s) => s.customerId == customerId).toList();
    final Map<String, Sale> salesMap = {for (var s in customerSalesList) s.id: s};
    final items = _saleItems.where((si) => salesMap.containsKey(si.saleId)).toList();

    final Map<String, List<SaleItem>> itemsBySale = {};
    for (var item in items) {
      itemsBySale.putIfAbsent(item.saleId, () => []).add(item);
    }

    final List<SaleItem> result = [];
    for (var entry in itemsBySale.entries) {
      final sale = salesMap[entry.key];
      final saleItems = entry.value;
      final saleTotal = sale?.totalAmount ?? 0;
      final baseSum = saleItems.fold<int>(0, (sum, si) => sum + si.totalPrice);

      int remainingTotal = saleTotal > 0 ? saleTotal : baseSum;

      for (int i = 0; i < saleItems.length; i++) {
        final si = saleItems[i];
        int effectiveTotal;
        if (saleTotal > 0 && baseSum > 0 && saleTotal != baseSum) {
          effectiveTotal = (i == saleItems.length - 1)
              ? remainingTotal
              : ((si.totalPrice * saleTotal) / baseSum).round();
          remainingTotal -= effectiveTotal;
        } else if (saleTotal > 0 && saleItems.length == 1) {
          effectiveTotal = saleTotal;
        } else {
          effectiveTotal = si.totalPrice;
        }

        final effectiveUnitPrice = si.quantity > 0 ? (effectiveTotal / si.quantity).round() : effectiveTotal;
        result.add(si.copyWith(
          totalPrice: effectiveTotal,
          unitPrice: effectiveUnitPrice,
        ));
      }
    }

    return result;
  }

  @override
  Future<void> returnProduct({
    required String saleItemId,
    required int collectedAmount,
    required String processedBy,
    required bool tallyOut,
    String? tallySaleItemId,
    String? tallyProductName,
    int? tallyAmount,
  }) async {
    final itemIndex = _saleItems.indexWhere((si) => si.id == saleItemId);
    if (itemIndex == -1) return;
    final item = _saleItems[itemIndex];
    _saleItems[itemIndex] = item.copyWith(status: 'returned');

    final saleIndex = _sales.indexWhere((s) => s.id == item.saleId);
    if (saleIndex != -1) {
      final sale = _sales[saleIndex];
      final customerId = sale.customerId;

      int actualTallyAmount = 0;
      int creditRemainder = collectedAmount;

      if (tallyOut) {
        if (tallyAmount != null) {
          actualTallyAmount = tallyAmount;
        } else {
          // Calculate customer outstanding before returned item's financed amount is reduced
          final customerSales = _sales.where((s) => s.customerId == customerId);
          final totalFinanced = customerSales.fold<int>(0, (sum, s) => sum + s.financedAmount);
          final totalCollected = _collections.where((c) => c.customerId == customerId && (c.status == 'PAYMENT' || c.status == 'PARTIAL_PAYMENT')).fold<int>(0, (sum, c) => sum + c.amount.toInt());
          final outstanding = totalFinanced - totalCollected;

          final unpaidPortion = item.totalPrice - collectedAmount;
          final otherOutstanding = outstanding - unpaidPortion;
          final actualOtherOutstanding = otherOutstanding < 0 ? 0 : otherOutstanding;
          actualTallyAmount = collectedAmount < actualOtherOutstanding ? collectedAmount : actualOtherOutstanding;
        }
        creditRemainder = collectedAmount - actualTallyAmount;
      }

      final pIndex = _products.indexWhere((p) => p.id == item.productId);
      final productName = pIndex != -1 ? _products[pIndex].name : 'Product';

      if (actualTallyAmount > 0) {
        final reasonText = tallyProductName != null
            ? 'Return Tally Out: $productName applied to $tallyProductName'
            : 'Return Tally Out: $productName';
        
        final Map<String, int> allocationMap = {};
        if (tallySaleItemId != null) {
          allocationMap[tallySaleItemId] = actualTallyAmount;
        }

        final finalReason = reasonText + (tallySaleItemId != null ? '&allocations=${jsonEncode(allocationMap)}' : '');

        _collections.add(Collection(
          id: UuidUtils.generate(),
          customerId: customerId,
          visitDatetime: DateTime.now(),
          status: 'PAYMENT',
          amount: actualTallyAmount.toDouble(),
          reason: finalReason,
          collectedBy: processedBy,
        ));

        if (tallySaleItemId != null) {
          final tIndex = _saleItems.indexWhere((si) => si.id == tallySaleItemId);
          if (tIndex != -1) {
            final tItem = _saleItems[tIndex];
            _saleItems[tIndex] = tItem.copyWith(collectedAmount: tItem.collectedAmount + actualTallyAmount);
          }
        }
      }

      if (creditRemainder > 0) {
        final customerIndex = _customers.indexWhere((c) => c.id == customerId);
        if (customerIndex != -1) {
          final cust = _customers[customerIndex];
          _customers[customerIndex] = cust.copyWith(credit: cust.credit + creditRemainder);
        }
      }

      final advanceReduction = collectedAmount < sale.advanceAmount ? collectedAmount : sale.advanceAmount;
      final financedReduction = item.totalPrice - advanceReduction;

      _sales[saleIndex] = sale.copyWith(
        totalAmount: (sale.totalAmount - item.totalPrice).clamp(0, 9999999),
        advanceAmount: (sale.advanceAmount - advanceReduction).clamp(0, 9999999),
        financedAmount: (sale.financedAmount - financedReduction).clamp(0, 9999999),
      );
    }

    // Restock product in catalog
    final pIndex = _products.indexWhere((p) => p.id == item.productId);
    if (pIndex != -1) {
      final p = _products[pIndex];
      _products[pIndex] = p.copyWith(stock: p.stock + item.quantity);
    }

    _syncController();
  }

  @override
  Future<void> settleProduct(String saleItemId) async {
    final itemIndex = _saleItems.indexWhere((si) => si.id == saleItemId);
    if (itemIndex != -1) {
      _saleItems[itemIndex] = _saleItems[itemIndex].copyWith(status: 'settled');
    }
    _syncController();
  }

  // ─── ProductRepository ──────────────────────────────────

  @override
  Future<List<Product>> getProducts() async => _products;

  @override
  Stream<List<Product>> watchProducts() async* {
    yield _products;
    yield* _updateController.stream.map((_) => _products);
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Product> addProduct({
    required String name,
    required String brand,
    required String sku,
    required int costPrice,
    required int sellingPrice,
    required int mrp,
    required int stock,
    required String categoryId,
    required int minimumStock,
    String? description,
    String? imageUrl,
  }) async {
    final product = Product(
      id: 'pr-${DateTime.now().millisecondsSinceEpoch}',
      sku: sku,
      name: name,
      brand: brand,
      categoryId: categoryId,
      minimumStock: minimumStock,
      stock: stock,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      mrp: mrp,
      imageUrl: imageUrl,
      description: description,
    );
    _products.add(product);
    _ref.read(syncProvider.notifier).incrementPending();
    AppHaptics.mediumImpact();
    _syncController();
    return product;
  }

  @override
  Future<void> updateProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      _syncController();
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
