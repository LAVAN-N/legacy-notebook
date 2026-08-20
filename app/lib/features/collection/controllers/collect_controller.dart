import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/outstanding.dart';
import '../../../data/providers.dart';
import '../../customer/controllers/customer_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class ProductAllocation {
  final String saleItemId;
  final String productName;
  final int totalPrice;
  final int collectedAmount;
  final int allocatedAmount;

  int get outstanding => totalPrice - collectedAmount;

  ProductAllocation({
    required this.saleItemId,
    required this.productName,
    required this.totalPrice,
    required this.collectedAmount,
    required this.allocatedAmount,
  });

  ProductAllocation copyWith({int? allocatedAmount}) {
    return ProductAllocation(
      saleItemId: saleItemId,
      productName: productName,
      totalPrice: totalPrice,
      collectedAmount: collectedAmount,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
    );
  }
}

class CollectScreenState {
  const CollectScreenState({
    required this.customer,
    required this.outstanding,
    required this.status, // PAYMENT, PARTIAL_PAYMENT, CARRY_FORWARD
    required this.amount,
    required this.notes,
    required this.errorMessage,
    required this.isSaving,
    required this.selectedDate,
    required this.collectionTarget, // 'SALE' or 'LEND'
    required this.allocations,
    required this.allocationType, // 'EQUALLY' or 'INDIVIDUALLY'
  });

  final Customer customer;
  final Outstanding outstanding;
  final String status;
  final int amount;
  final String notes;
  final String? errorMessage;
  final bool isSaving;
  final DateTime selectedDate;
  final String collectionTarget;
  final List<ProductAllocation> allocations;
  final String allocationType;

  CollectScreenState copyWith({
    Customer? customer,
    Outstanding? outstanding,
    String? status,
    int? amount,
    String? notes,
    String? errorMessage,
    bool? isSaving,
    DateTime? selectedDate,
    String? collectionTarget,
    List<ProductAllocation>? allocations,
    String? allocationType,
  }) {
    return CollectScreenState(
      customer: customer ?? this.customer,
      outstanding: outstanding ?? this.outstanding,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      errorMessage: errorMessage, // Nullable override
      isSaving: isSaving ?? this.isSaving,
      selectedDate: selectedDate ?? this.selectedDate,
      collectionTarget: collectionTarget ?? this.collectionTarget,
      allocations: allocations ?? this.allocations,
      allocationType: allocationType ?? this.allocationType,
    );
  }
}

final collectControllerProvider = StateNotifierProvider.autoDispose.family<CollectController, CollectScreenState, String>((ref, customerId) {
  return CollectController(ref, customerId);
});

class CollectController extends StateNotifier<CollectScreenState> {
  CollectController(this._ref, this._customerId)
      : super(CollectScreenState(
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
          status: 'PAYMENT',
          amount: 0,
          notes: '',
          errorMessage: null,
          isSaving: false,
          selectedDate: DateTime.now(),
          collectionTarget: 'SALE',
          allocations: const [],
          allocationType: 'EQUALLY',
        )) {
    _init();
  }

  final Ref _ref;
  final String _customerId;

  List<ProductAllocation> _distributeEqually(List<ProductAllocation> items, int totalAmount) {
    var result = items.map((e) => e.copyWith(allocatedAmount: 0)).toList();
    int remaining = totalAmount;
    
    bool distributedAny = true;
    while (remaining > 0 && distributedAny) {
      distributedAny = false;
      final active = result.where((e) => e.outstanding > e.allocatedAmount).toList();
      if (active.isEmpty) break;
      
      final share = remaining ~/ active.length;
      if (share > 0) {
        for (var item in active) {
          final idx = result.indexOf(item);
          final possibleAdd = item.outstanding - item.allocatedAmount;
          final added = share < possibleAdd ? share : possibleAdd;
          result[idx] = result[idx].copyWith(
            allocatedAmount: result[idx].allocatedAmount + added,
          );
          remaining -= added;
          distributedAny = true;
        }
      } else {
        for (var item in active) {
          if (remaining <= 0) break;
          final idx = result.indexOf(item);
          result[idx] = result[idx].copyWith(
            allocatedAmount: result[idx].allocatedAmount + 1,
          );
          remaining -= 1;
          distributedAny = true;
        }
      }
    }
    return result;
  }

  void _init() async {
    final customerRepo = _ref.read(customerRepositoryProvider);
    final customer = await customerRepo.getCustomerById(_customerId);
    final outstanding = await customerRepo.getCustomerOutstanding(_customerId);

    if (customer != null) {
      final isLendEnabled = outstanding.lendOutstanding > 0;
      final isSaleEnabled = outstanding.saleOutstanding > 0;

      String defaultTarget = 'SALE';
      int defaultAmount = outstanding.saleOutstanding > 0 ? outstanding.saleOutstanding : 0;

      if (!isSaleEnabled && isLendEnabled) {
        defaultTarget = 'LEND';
        defaultAmount = outstanding.lendOutstanding > 0 ? outstanding.lendOutstanding : 0;
      }

      final saleRepo = _ref.read(saleRepositoryProvider);
      final productRepo = _ref.read(productRepositoryProvider);
      
      final saleItems = await saleRepo.getSaleItemsForCustomer(_customerId);
      final productsList = await productRepo.getProducts();
      final productMap = {for (var p in productsList) p.id: p.name};

      final activePurchases = saleItems.where((item) => 
        item.status == 'purchased' && 
        (item.totalPrice - item.collectedAmount) > 0
      ).map((item) {
        final name = productMap[item.productId] ?? 'Unknown Product';
        return ProductAllocation(
          saleItemId: item.id,
          productName: name,
          totalPrice: item.totalPrice,
          collectedAmount: item.collectedAmount,
          allocatedAmount: 0,
        );
      }).toList();

      List<ProductAllocation> initialAllocations = activePurchases;
      if (defaultTarget == 'SALE' && defaultAmount > 0) {
        initialAllocations = _distributeEqually(activePurchases, defaultAmount);
      }

      state = state.copyWith(
        customer: customer,
        outstanding: outstanding,
        collectionTarget: defaultTarget,
        amount: defaultAmount,
        allocations: initialAllocations,
        allocationType: 'EQUALLY',
      );
    }
  }

  void toggleAllocationType(String type) {
    List<ProductAllocation> updated = state.allocations;
    int amount = state.amount;
    
    if (type == 'EQUALLY') {
      updated = _distributeEqually(state.allocations, amount);
    } else {
      amount = state.allocations.fold(0, (sum, item) => sum + item.allocatedAmount);
    }
    
    state = state.copyWith(
      allocationType: type,
      allocations: updated,
      amount: amount,
      errorMessage: null,
    );
  }

  void updateIndividualAllocation(String saleItemId, int allocAmount) {
    if (state.allocationType != 'INDIVIDUALLY') return;
    
    final updated = state.allocations.map((item) {
      if (item.saleItemId == saleItemId) {
        final clamped = allocAmount.clamp(0, item.outstanding);
        return item.copyWith(allocatedAmount: clamped);
      }
      return item;
    }).toList();
    
    final newTotal = updated.fold(0, (sum, item) => sum + item.allocatedAmount);
    
    String? error;
    final maxOutstanding = state.outstanding.saleOutstanding;
    if (state.status == 'PAYMENT' && newTotal > maxOutstanding) {
      error = 'Payment exceeds outstanding balance!';
    }
    
    state = state.copyWith(
      allocations: updated,
      amount: newTotal,
      errorMessage: error,
    );
  }

  void updateCollectionTarget(String target) {
    final maxOutstanding = target == 'LEND'
        ? state.outstanding.lendOutstanding
        : state.outstanding.saleOutstanding;

    int defaultAmount = 0;
    if (state.status == 'PAYMENT') {
      defaultAmount = maxOutstanding > 0 ? maxOutstanding : 0;
    } else if (state.status == 'PARTIAL_PAYMENT') {
      defaultAmount = 0;
    } else {
      defaultAmount = 0;
    }

    List<ProductAllocation> updated = state.allocations;
    if (target == 'SALE') {
      if (state.allocationType == 'EQUALLY') {
        updated = _distributeEqually(state.allocations, defaultAmount);
      }
    } else {
      updated = state.allocations.map((e) => e.copyWith(allocatedAmount: 0)).toList();
    }

    state = state.copyWith(
      collectionTarget: target,
      amount: defaultAmount,
      allocations: updated,
      errorMessage: null,
    );
  }

  void updateStatus(String status) {
    int defaultAmount = 0;
    final maxOutstanding = state.collectionTarget == 'LEND'
        ? state.outstanding.lendOutstanding
        : state.outstanding.saleOutstanding;

    if (status == 'PAYMENT') {
      defaultAmount = maxOutstanding > 0 ? maxOutstanding : 0;
    } else if (status == 'PARTIAL_PAYMENT') {
      defaultAmount = 0;
    } else {
      defaultAmount = 0; // Carry Forward
    }

    List<ProductAllocation> updated = state.allocations;
    if (state.collectionTarget == 'SALE') {
      if (state.allocationType == 'EQUALLY') {
        updated = _distributeEqually(state.allocations, defaultAmount);
      }
    }

    state = state.copyWith(
      status: status,
      amount: defaultAmount,
      allocations: updated,
      errorMessage: null,
    );
  }

  void updateAmount(int amount) {
    String? error;
    final maxOutstanding = state.collectionTarget == 'LEND'
        ? state.outstanding.lendOutstanding
        : state.outstanding.saleOutstanding;

    if (amount < 0) {
      error = 'Amount cannot be negative';
    } else if (state.status == 'PAYMENT' && amount > maxOutstanding) {
      error = 'Payment exceeds outstanding balance!';
    }

    List<ProductAllocation> updated = state.allocations;
    if (state.collectionTarget == 'SALE' && state.allocationType == 'EQUALLY') {
      updated = _distributeEqually(state.allocations, amount);
    }

    state = state.copyWith(
      amount: amount,
      allocations: updated,
      errorMessage: error,
    );
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void updateDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  Future<bool> saveCollection() async {
    if (state.isSaving) return false;

    // Validations
    if (state.amount < 0) {
      state = state.copyWith(errorMessage: 'Collection amount cannot be negative');
      return false;
    }
    if (state.status == 'PARTIAL_PAYMENT' && state.amount <= 0) {
      state = state.copyWith(errorMessage: 'Partial payment amount must be greater than 0');
      return false;
    }
    if (state.status == 'PARTIAL_PAYMENT' && state.notes.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter notes explaining the partial payment');
      return false;
    }
    if (state.status == 'CARRY_FORWARD' && state.notes.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please specify the reason for Carry Forward');
      return false;
    }

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final collectionRepo = _ref.read(collectionRepositoryProvider);
      final finalReason = 'COLLECTION_TARGET:target=${state.collectionTarget}&note=${state.notes}';
      
      final Map<String, int> allocationMap = {};
      if (state.collectionTarget == 'SALE' && state.status != 'CARRY_FORWARD') {
        for (var item in state.allocations) {
          if (item.allocatedAmount > 0) {
            allocationMap[item.saleItemId] = item.allocatedAmount;
          }
        }
      }

      await collectionRepo.saveCollection(
        customerId: _customerId,
        status: state.status,
        amount: state.status == 'CARRY_FORWARD' ? 0.0 : state.amount.toDouble(),
        reason: finalReason,
        collectedBy: 'Owner',
        customDate: state.selectedDate,
        allocations: allocationMap,
      );

      _ref.invalidate(customerDetailControllerProvider(_customerId));
      _ref.invalidate(dashboardControllerProvider);

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Failed to save: ${e.toString()}');
      return false;
    }
  }
}
