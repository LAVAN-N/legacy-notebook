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
  });

  final Customer customer;
  final Outstanding outstanding;
  final String status;
  final int amount;
  final String notes;
  final String? errorMessage;
  final bool isSaving;

  CollectScreenState copyWith({
    Customer? customer,
    Outstanding? outstanding,
    String? status,
    int? amount,
    String? notes,
    String? errorMessage,
    bool? isSaving,
  }) {
    return CollectScreenState(
      customer: customer ?? this.customer,
      outstanding: outstanding ?? this.outstanding,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      errorMessage: errorMessage, // Nullable override
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

final collectControllerProvider = AutoDisposeStateNotifierProviderFamily<CollectController, CollectScreenState, String>((ref, customerId) {
  return CollectController(ref, customerId);
});

class CollectController extends StateNotifier<CollectScreenState> {
  CollectController(this._ref, this._customerId)
      : super(const CollectScreenState(
          customer: Customer(
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
          outstanding: Outstanding(customerId: '', totalFinanced: 0, totalCollected: 0, outstandingAmount: 0),
          status: 'PAYMENT',
          amount: 0,
          notes: '',
          errorMessage: null,
          isSaving: false,
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
      state = state.copyWith(
        customer: customer,
        outstanding: outstanding,
        amount: outstanding.outstandingAmount, // Default to full outstanding for PAYMENT
      );
    }
  }

  void updateStatus(String status) {
    int defaultAmount = 0;
    if (status == 'PAYMENT') {
      defaultAmount = state.outstanding.outstandingAmount;
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
    if (amount < 0) {
      error = 'Amount cannot be negative';
    } else if (state.status == 'PAYMENT' && amount > state.outstanding.outstandingAmount) {
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
      await collectionRepo.saveCollection(
        customerId: _customerId,
        status: state.status,
        amount: state.status == 'CARRY_FORWARD' ? 0 : state.amount,
        reason: state.notes.isNotEmpty ? state.notes : null,
        collectedBy: 'Ramesh (Collector)',
      );
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Failed to save: ${e.toString()}');
      return false;
    }
  }
}
