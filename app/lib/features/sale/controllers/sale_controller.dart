import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/outstanding.dart';
import '../../../data/models/product.dart';
import '../../../data/providers.dart';
import '../../customer/controllers/customer_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class SaleItemInput {
  SaleItemInput({
    required this.product,
    required this.quantity,
    int? customPrice,
  }) : price = customPrice ?? product.sellingPrice;

  final Product product;
  int quantity;
  int price;

  int get subtotal => price * quantity;
}

class SaleItemAllocation {
  final String productId;
  final String productName;
  final int itemSaleCost;
  final int allocatedAmount;

  int get remainingDue => itemSaleCost - allocatedAmount;

  SaleItemAllocation({
    required this.productId,
    required this.productName,
    required this.itemSaleCost,
    required this.allocatedAmount,
  });

  SaleItemAllocation copyWith({int? allocatedAmount}) {
    return SaleItemAllocation(
      productId: productId,
      productName: productName,
      itemSaleCost: itemSaleCost,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
    );
  }
}

class SaleScreenState {
  const SaleScreenState({
    required this.customer,
    required this.outstanding,
    required this.catalog,
    required this.lineItems,
    required this.advanceAmount,
    required this.isDiscounted,
    this.creditChargeValue = 0.0,
    this.creditChargeType = 'RUPEE',
    required this.remarks,
    required this.errorMessage,
    required this.isSaving,
    required this.selectedDate,
    this.isLend = false,
    this.lendAmount = 0,
    this.isCreditApplied = false,
    this.allocationType = 'EQUALLY',
    this.customAllocations = const {},
  });

  final Customer customer;
  final Outstanding outstanding;
  final List<Product> catalog;
  final List<SaleItemInput> lineItems;
  final int advanceAmount;
  final bool isDiscounted;
  final double creditChargeValue;
  final String creditChargeType; // 'RUPEE' or 'PERCENT'
  final String remarks;
  final String? errorMessage;
  final bool isSaving;
  final DateTime selectedDate;
  final bool isLend;
  final int lendAmount;
  final bool isCreditApplied;
  final String allocationType; // 'EQUALLY' or 'INDIVIDUALLY'
  final Map<String, int> customAllocations;

  int get totalAmount => isLend ? lendAmount : (lineItems.fold<int>(0, (sum, item) => sum + item.subtotal) ~/ 100);

  int get creditChargeAmount {
    if (isDiscounted) return 0;
    if (creditChargeType == 'PERCENT') {
      return (totalAmount * creditChargeValue / 100.0).round();
    } else {
      return creditChargeValue.round();
    }
  }

  int get grandTotal => totalAmount + creditChargeAmount;
  int get finalAmount => isDiscounted ? advanceAmount : grandTotal;
  int get discountAmount => isDiscounted ? (totalAmount - advanceAmount).clamp(0, totalAmount) : 0;
  int get appliedCreditAmount => isCreditApplied ? (customer.credit < grandTotal ? customer.credit : grandTotal) : 0;
  int get creditAdded => isDiscounted ? 0 : (grandTotal - advanceAmount - appliedCreditAmount).clamp(0, 9999999);
  String get saleType => creditAdded == 0 ? 'READY' : 'CREDIT';

  List<SaleItemAllocation> get allocations {
    if (lineItems.isEmpty || isLend) return [];

    final int totalBase = totalAmount;
    final int netAdjustment = creditChargeAmount - discountAmount;
    final int totalInitialPaid = advanceAmount + appliedCreditAmount;

    final List<SaleItemAllocation> list = [];
    int remainingPaid = totalInitialPaid;

    for (int i = 0; i < lineItems.length; i++) {
      final item = lineItems[i];
      final baseItemTotal = item.subtotal ~/ 100;
      final int itemAdjustment = (totalBase > 0)
          ? ((baseItemTotal * netAdjustment) / totalBase).round()
          : 0;
      final itemCost = baseItemTotal + itemAdjustment;

      int allocated;
      if (allocationType == 'INDIVIDUALLY') {
        allocated = (customAllocations[item.product.id] ?? 0).clamp(0, itemCost);
      } else {
        if (i == lineItems.length - 1) {
          allocated = remainingPaid.clamp(0, itemCost);
        } else {
          final share = (totalInitialPaid / lineItems.length).floor();
          allocated = share.clamp(0, itemCost);
          remainingPaid -= allocated;
        }
      }

      list.add(SaleItemAllocation(
        productId: item.product.id,
        productName: item.product.name,
        itemSaleCost: itemCost,
        allocatedAmount: allocated,
      ));
    }
    return list;
  }

  SaleScreenState copyWith({
    Customer? customer,
    Outstanding? outstanding,
    List<Product>? catalog,
    List<SaleItemInput>? lineItems,
    int? advanceAmount,
    bool? isDiscounted,
    double? creditChargeValue,
    String? creditChargeType,
    String? remarks,
    String? errorMessage,
    bool? isSaving,
    DateTime? selectedDate,
    bool? isLend,
    int? lendAmount,
    bool? isCreditApplied,
    String? allocationType,
    Map<String, int>? customAllocations,
  }) {
    return SaleScreenState(
      customer: customer ?? this.customer,
      outstanding: outstanding ?? this.outstanding,
      catalog: catalog ?? this.catalog,
      lineItems: lineItems ?? this.lineItems,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      isDiscounted: isDiscounted ?? this.isDiscounted,
      creditChargeValue: creditChargeValue ?? this.creditChargeValue,
      creditChargeType: creditChargeType ?? this.creditChargeType,
      remarks: remarks ?? this.remarks,
      errorMessage: errorMessage, // Nullable override
      isSaving: isSaving ?? this.isSaving,
      selectedDate: selectedDate ?? this.selectedDate,
      isLend: isLend ?? this.isLend,
      lendAmount: lendAmount ?? this.lendAmount,
      isCreditApplied: isCreditApplied ?? this.isCreditApplied,
      allocationType: allocationType ?? this.allocationType,
      customAllocations: customAllocations ?? this.customAllocations,
    );
  }
}

final saleControllerProvider = StateNotifierProvider.autoDispose.family<SaleController, SaleScreenState, String>((ref, customerId) {
  return SaleController(ref, customerId);
});

class SaleController extends StateNotifier<SaleScreenState> {
  SaleController(this._ref, this._customerId)
      : super(SaleScreenState(
          customer: const Customer(
            id: '',
            customerCode: '',
            name: '',
            phone: '',
            address: '',
            weekdayId: '',
            placeId: '',
            areaId: '',
            status: 'ACTIVE',
          ),
          outstanding: const Outstanding(customerId: '', totalFinanced: 0, totalCollected: 0, outstandingAmount: 0),
          catalog: const [],
          lineItems: const [],
          advanceAmount: 0,
          isDiscounted: false,
          creditChargeValue: 0.0,
          creditChargeType: 'RUPEE',
          remarks: '',
          errorMessage: null,
          isSaving: false,
          selectedDate: DateTime.now(),
          isLend: false,
          lendAmount: 0,
          allocationType: 'EQUALLY',
          customAllocations: const {},
        )) {
    _init();

    // Reactively listen to the products stream provider for catalog updates
    _ref.listen<AsyncValue<List<Product>>>(
      productsStreamProvider,
      (previous, next) {
        next.whenOrNull(
          data: (products) {
            state = state.copyWith(catalog: products);
          },
        );
      },
      fireImmediately: true,
    );
  }

  final Ref _ref;
  final String _customerId;

  void _init() async {
    final customerRepo = _ref.read(customerRepositoryProvider);
    final productRepo = _ref.read(productRepositoryProvider);

    final customer = await customerRepo.getCustomerById(_customerId);
    final outstanding = await customerRepo.getCustomerOutstanding(_customerId);
    final products = await productRepo.getProducts();

    if (customer != null) {
      state = state.copyWith(
        customer: customer,
        outstanding: outstanding,
        catalog: products,
      );
    }
  }

  void setLendMode(bool isLend) {
    state = state.copyWith(
      isLend: isLend,
      advanceAmount: 0, // Reset advance in lend mode
      isDiscounted: false, // Reset discount in lend mode
      errorMessage: null,
    );
  }

  void updateLendAmount(int amount) {
    if (amount < 0) return;
    state = state.copyWith(lendAmount: amount, errorMessage: null);
  }

  void addProduct(Product product, {int? quantity, int? price}) {
    final qty = quantity ?? 1;
    if (product.stock <= 0) {
      state = state.copyWith(errorMessage: 'Cannot add ${product.name}: Out of Stock');
      return;
    }

    final existingIndex = state.lineItems.indexWhere((item) => item.product.id == product.id);

    final list = List<SaleItemInput>.from(state.lineItems);
    if (existingIndex != -1) {
      final existingItem = list[existingIndex];
      final newQty = existingItem.quantity + qty;
      if (newQty > product.stock) {
        state = state.copyWith(errorMessage: 'Cannot add more: Max available stock reached');
        return;
      }
      existingItem.quantity = newQty;
      if (price != null) {
        existingItem.price = price;
      }
    } else {
      if (qty > product.stock) {
        state = state.copyWith(errorMessage: 'Cannot add more: Max available stock reached');
        return;
      }
      list.add(SaleItemInput(
        product: product,
        quantity: qty,
        customPrice: price,
      ));
    }

    state = state.copyWith(lineItems: list, errorMessage: null);
  }

  void updateQuantity(String productId, int quantity) {
    final index = state.lineItems.indexWhere((item) => item.product.id == productId);
    if (index == -1) return;

    final list = List<SaleItemInput>.from(state.lineItems);
    if (quantity <= 0) {
      list.removeAt(index);
    } else {
      final item = list[index];
      if (quantity > item.product.stock) {
        state = state.copyWith(errorMessage: 'Only ${item.product.stock} units available');
        return;
      }
      item.quantity = quantity;
    }

    // Reset advance if it exceeds new total
    int newAdvance = state.advanceAmount;
    final newTotal = list.fold<int>(0, (sum, i) => sum + i.subtotal) ~/ 100;
    if (newAdvance > newTotal) {
      newAdvance = newTotal;
    }

    state = state.copyWith(lineItems: list, advanceAmount: newAdvance, errorMessage: null);
  }

  void updateCreditChargeValue(double val) {
    if (val < 0) return;
    state = state.copyWith(creditChargeValue: val, errorMessage: null);
  }

  void toggleCreditChargeType(String type) {
    if (type != 'RUPEE' && type != 'PERCENT') return;
    state = state.copyWith(creditChargeType: type, errorMessage: null);
  }

  void toggleAllocationType(String type) {
    if (type == state.allocationType) return;

    if (type == 'INDIVIDUALLY') {
      final currentAllocs = state.allocations;
      final Map<String, int> map = {
        for (var a in currentAllocs) a.productId: a.allocatedAmount
      };
      state = state.copyWith(allocationType: 'INDIVIDUALLY', customAllocations: map, errorMessage: null);
    } else {
      state = state.copyWith(allocationType: 'EQUALLY', customAllocations: const {}, errorMessage: null);
    }
  }

  void updateIndividualAllocation(String productId, int amount) {
    final newMap = Map<String, int>.from(state.customAllocations);
    newMap[productId] = amount;

    state = state.copyWith(
      customAllocations: newMap,
      errorMessage: null,
    );
  }

  void syncAdvanceToAllocations() {
    final totalAllocated = state.allocations.fold<int>(0, (sum, a) => sum + a.allocatedAmount);
    final newAdvance = (totalAllocated - state.appliedCreditAmount).clamp(0, state.grandTotal);
    state = state.copyWith(advanceAmount: newAdvance, errorMessage: null);
  }

  void autoFillField([String? productId]) {
    final target = state.advanceAmount + state.appliedCreditAmount;
    final totalAllocated = state.allocations.fold<int>(0, (sum, a) => sum + a.allocatedAmount);
    int remaining = target - totalAllocated;
    if (remaining <= 0) return;

    final map = Map<String, int>.from(state.customAllocations);
    if (productId != null) {
      final allocs = state.allocations;
      final item = allocs.firstWhere((a) => a.productId == productId, orElse: () => allocs.first);
      final current = item.allocatedAmount;
      final maxCanTake = item.itemSaleCost - current;
      if (maxCanTake > 0) {
        final add = remaining < maxCanTake ? remaining : maxCanTake;
        map[item.productId] = current + add;
        state = state.copyWith(customAllocations: map, errorMessage: null);
      }
      return;
    }

    final allocs = state.allocations;
    for (final a in allocs) {
      if (remaining <= 0) break;
      final current = a.allocatedAmount;
      final maxCanTake = a.itemSaleCost - current;
      if (maxCanTake > 0) {
        final add = remaining < maxCanTake ? remaining : maxCanTake;
        map[a.productId] = current + add;
        remaining -= add;
      }
    }
    state = state.copyWith(customAllocations: map, errorMessage: null);
  }

  void autoBalanceRemainingSaleAllocation() => autoFillField();

  void updateAdvance(int advance) {
    String? error;
    if (advance < 0) {
      error = 'Advance cannot be negative';
    } else if (advance > state.grandTotal) {
      error = 'Advance paid cannot exceed total purchase value!';
    }

    state = state.copyWith(
      advanceAmount: advance,
      errorMessage: error,
      customAllocations: const {},
      allocationType: 'EQUALLY',
    );
  }

  void toggleDiscounted(bool isDiscounted) {
    state = state.copyWith(
      isDiscounted: isDiscounted,
      errorMessage: null,
    );
  }

  void updateRemarks(String remarks) {
    state = state.copyWith(remarks: remarks);
  }

  void updateDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void toggleApplyCredit(bool apply) {
    state = state.copyWith(isCreditApplied: apply, errorMessage: null);
  }

  Future<bool> saveSale() async {
    if (state.isSaving) return false;

    if (!state.isLend && state.lineItems.isEmpty) {
      state = state.copyWith(errorMessage: 'Please add at least one item to purchase.');
      return false;
    }

    if (state.isLend && state.lendAmount <= 0) {
      state = state.copyWith(errorMessage: 'Lend amount must be greater than zero.');
      return false;
    }

    if (state.advanceAmount < 0) {
      state = state.copyWith(errorMessage: 'Advance amount cannot be negative.');
      return false;
    }

    if (state.advanceAmount > state.grandTotal) {
      state = state.copyWith(errorMessage: 'Advance paid cannot exceed total purchase value.');
      return false;
    }

    if (!state.isLend &&
        state.lineItems.isNotEmpty &&
        state.allocationType == 'INDIVIDUALLY') {
      final totalAllocated = state.allocations.fold<int>(0, (sum, a) => sum + a.allocatedAmount);
      final targetPayment = state.advanceAmount + state.appliedCreditAmount;
      if (totalAllocated != targetPayment) {
        state = state.copyWith(
          errorMessage: 'Total product allocations (₹$totalAllocated) must match total down payment (₹$targetPayment)',
        );
        return false;
      }
    }

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final saleRepo = _ref.read(saleRepositoryProvider);
      
      final mappedItems = state.isLend
          ? <Map<String, dynamic>>[]
          : state.lineItems.map((item) {
              final alloc = state.allocations.firstWhere(
                (a) => a.productId == item.product.id,
                orElse: () => SaleItemAllocation(
                  productId: item.product.id,
                  productName: item.product.name,
                  itemSaleCost: item.subtotal ~/ 100,
                  allocatedAmount: 0,
                ),
              );
              return {
                'productId': item.product.id,
                'quantity': item.quantity,
                'unitPrice': item.price ~/ 100,
                'allocatedAmount': alloc.allocatedAmount,
              };
            }).toList();

      final finalRemarks = state.isLend
          ? 'LEND_DETAILS:principal=${state.lendAmount}&charge=${state.creditChargeAmount}&note=${state.remarks}'
          : (state.remarks.isNotEmpty ? state.remarks : null);

      await saleRepo.saveSale(
        customerId: _customerId,
        items: mappedItems,
        advanceAmount: state.advanceAmount,
        discount: state.discountAmount,
        creditCharge: state.creditChargeAmount,
        soldBy: 'Owner',
        remarks: finalRemarks,
        customDate: state.selectedDate,
        lendAmount: state.isLend ? state.lendAmount : null,
        appliedCredit: state.appliedCreditAmount,
      );

      _ref.invalidate(customerDetailControllerProvider(_customerId));
      _ref.invalidate(dashboardControllerProvider);

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Failed to record sale: ${e.toString()}');
      return false;
    }
  }
}
