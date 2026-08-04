import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/outstanding.dart';
import '../../../data/models/product.dart';
import '../../../data/providers.dart';

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
  int get creditAdded => isDiscounted ? 0 : (grandTotal - advanceAmount).clamp(0, 9999999);
  String get saleType => creditAdded == 0 ? 'READY' : 'CREDIT';

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
    );
  }
}

final saleControllerProvider = AutoDisposeStateNotifierProviderFamily<SaleController, SaleScreenState, String>((ref, customerId) {
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

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final saleRepo = _ref.read(saleRepositoryProvider);
      
      final mappedItems = state.isLend
          ? <Map<String, dynamic>>[]
          : state.lineItems.map((item) => {
              'productId': item.product.id,
              'quantity': item.quantity,
              'unitPrice': item.price ~/ 100,
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
      );

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Failed to record sale: ${e.toString()}');
      return false;
    }
  }
}
