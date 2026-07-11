import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/outstanding.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/sale_repository.dart';
import '../../../data/providers.dart';

class SaleItemInput {
  SaleItemInput({
    required this.product,
    required this.quantity,
  });

  final Product product;
  int quantity;

  int get subtotal => product.price * quantity;
}

class SaleScreenState {
  const SaleScreenState({
    required this.customer,
    required this.outstanding,
    required this.catalog,
    required this.lineItems,
    required this.advanceAmount,
    required this.remarks,
    required this.errorMessage,
    required this.isSaving,
  });

  final Customer customer;
  final Outstanding outstanding;
  final List<Product> catalog;
  final List<SaleItemInput> lineItems;
  final int advanceAmount;
  final String remarks;
  final String? errorMessage;
  final bool isSaving;

  int get totalAmount => lineItems.fold<int>(0, (sum, item) => sum + item.subtotal);
  int get creditAdded => (totalAmount - advanceAmount).clamp(0, 9999999);
  String get saleType => creditAdded == 0 ? 'READY' : 'CREDIT';

  SaleScreenState copyWith({
    Customer? customer,
    Outstanding? outstanding,
    List<Product>? catalog,
    List<SaleItemInput>? lineItems,
    int? advanceAmount,
    String? remarks,
    String? errorMessage,
    bool? isSaving,
  }) {
    return SaleScreenState(
      customer: customer ?? this.customer,
      outstanding: outstanding ?? this.outstanding,
      catalog: catalog ?? this.catalog,
      lineItems: lineItems ?? this.lineItems,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      remarks: remarks ?? this.remarks,
      errorMessage: errorMessage, // Nullable override
      isSaving: isSaving ?? this.isSaving,
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
            sequenceNumber: 0,
            status: 'ACTIVE',
          ),
          outstanding: const Outstanding(customerId: '', totalFinanced: 0, totalCollected: 0, outstandingAmount: 0),
          catalog: [],
          lineItems: [],
          advanceAmount: 0,
          remarks: '',
          errorMessage: null,
          isSaving: false,
        )) {
    _init();
  }

  final Ref _ref;
  final String _customerId;

  void _init() async {
    final customerRepo = _ref.read(customerRepositoryProvider);
    final productRepo = _ref.read(productRepositoryProvider);

    final customer = await customerRepo.getCustomerById(_customerId);
    final outstanding = await customerRepo.getCustomerOutstanding(_customerId);
    final catalog = await productRepo.getProducts();

    if (customer != null) {
      state = state.copyWith(
        customer: customer,
        outstanding: outstanding,
        catalog: catalog,
      );
    }
  }

  void addProduct(Product product) {
    if (product.stock <= 0) {
      state = state.copyWith(errorMessage: 'Cannot add ${product.name}: Out of Stock');
      return;
    }

    final existingIndex = state.lineItems.indexWhere((item) => item.product.id == product.id);

    final list = List<SaleItemInput>.from(state.lineItems);
    if (existingIndex != -1) {
      final existingItem = list[existingIndex];
      if (existingItem.quantity >= product.stock) {
        state = state.copyWith(errorMessage: 'Cannot add more: Max available stock reached');
        return;
      }
      existingItem.quantity++;
    } else {
      list.add(SaleItemInput(product: product, quantity: 1));
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
    final newTotal = list.fold<int>(0, (sum, i) => sum + i.subtotal);
    if (newAdvance > newTotal) {
      newAdvance = newTotal;
    }

    state = state.copyWith(lineItems: list, advanceAmount: newAdvance, errorMessage: null);
  }

  void updateAdvance(int advance) {
    String? error;
    if (advance > state.totalAmount) {
      error = 'Advance paid cannot exceed total purchase value!';
    }

    state = state.copyWith(
      advanceAmount: advance,
      errorMessage: error,
    );
  }

  void updateRemarks(String remarks) {
    state = state.copyWith(remarks: remarks);
  }

  Future<bool> saveSale() async {
    if (state.isSaving) return false;

    if (state.lineItems.isEmpty) {
      state = state.copyWith(errorMessage: 'Please add at least one item to purchase.');
      return false;
    }

    if (state.advanceAmount > state.totalAmount) {
      state = state.copyWith(errorMessage: 'Advance paid cannot exceed total purchase value.');
      return false;
    }

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final saleRepo = _ref.read(saleRepositoryProvider);
      
      final mappedItems = state.lineItems.map((item) => {
        'productId': item.product.id,
        'quantity': item.quantity,
        'unitPrice': item.product.price,
      }).toList();

      await saleRepo.saveSale(
        customerId: _customerId,
        items: mappedItems,
        advanceAmount: state.advanceAmount,
        soldBy: 'Ramesh (Collector)',
        remarks: state.remarks.isNotEmpty ? state.remarks : null,
      );

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Failed to record sale: ${e.toString()}');
      return false;
    }
  }
}
