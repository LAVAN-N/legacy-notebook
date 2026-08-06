import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/data/models/customer.dart';
import '/data/models/outstanding.dart';
import '/data/providers.dart';

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
    );
  }
}

final collectControllerProvider = AutoDisposeStateNotifierProviderFamily<CollectController, CollectScreenState, String>((ref, customerId) {
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
        )) {
    _init();
  }

  final Ref _ref;
  final String _customerId;

  void _init() async {
    final customerRepo = _ref.read(customerRepositoryProvider);
    final customer = await customerRepo.getCustomerById(_customerId);
    final outstanding = await customerRepo.getCustomerOutstanding(_customerId);

    if (customer != null) {
      final isLendEnabled = outstanding.lendOutstanding > 0;
      final isSaleEnabled = outstanding.saleOutstanding > 0;

      String defaultTarget = 'SALE';
      int defaultAmount = outstanding.saleOutstanding;

      if (!isSaleEnabled && isLendEnabled) {
        defaultTarget = 'LEND';
        defaultAmount = outstanding.lendOutstanding;
      }

      state = state.copyWith(
        customer: customer,
        outstanding: outstanding,
        collectionTarget: defaultTarget,
        amount: defaultAmount,
      );
    }
  }

  void updateCollectionTarget(String target) {
    state = state.copyWith(
      collectionTarget: target,
      errorMessage: null,
    );
    updateStatus(state.status);
  }

  void updateStatus(String status) {
    int defaultAmount = 0;
    final maxOutstanding = state.collectionTarget == 'LEND'
        ? state.outstanding.lendOutstanding
        : state.outstanding.saleOutstanding;

    if (status == 'PAYMENT') {
      defaultAmount = maxOutstanding;
    } else if (status == 'PARTIAL_PAYMENT') {
      defaultAmount = 0;
    } else {
      defaultAmount = 0; // Carry Forward
    }

    state = state.copyWith(
      status: status,
      amount: defaultAmount,
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
    state = state.copyWith(
      amount: amount,
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
      await collectionRepo.saveCollection(
        customerId: _customerId,
        status: state.status,
        amount: state.status == 'CARRY_FORWARD' ? 0.0 : state.amount.toDouble(),
        reason: finalReason,
        collectedBy: 'Owner',
        customDate: state.selectedDate,
      );
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Failed to save: ${e.toString()}');
      return false;
    }
  }
}
