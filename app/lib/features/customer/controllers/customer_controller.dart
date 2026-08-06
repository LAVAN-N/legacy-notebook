import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/outstanding.dart';
import '../../../data/models/activity.dart';
import '../../../data/providers.dart';

class CustomerDetailData {
  const CustomerDetailData({
    required this.customer,
    required this.outstanding,
    required this.timeline,
  });

  final Customer customer;
  final Outstanding outstanding;
  final List<Activity> timeline;
}

final customerDetailControllerProvider = AutoDisposeAsyncNotifierProviderFamily<CustomerDetailNotifier, CustomerDetailData, String>(() {
  return CustomerDetailNotifier();
});

class CustomerDetailNotifier extends AutoDisposeFamilyAsyncNotifier<CustomerDetailData, String> {
  bool _isDisposed = false;

  @override
  Future<CustomerDetailData> build(String arg) async {
    final customerRepo = ref.read(customerRepositoryProvider);

    // 1. Fetch all 3 initial snapshots in PARALLEL — not sequentially
    final results = await Future.wait([
      customerRepo.getCustomerById(arg),
      customerRepo.getCustomerOutstanding(arg),
      customerRepo.getCustomerTimeline(arg),
    ]);

    final customer = results[0] as Customer?;
    if (customer == null) throw Exception('Customer not found');
    final outstanding = results[1] as Outstanding;
    final timeline = results[2] as List<Activity>;

    // 2. Subscribe to real-time streams ONLY for change notifications.
    //    skipInitialFetch: true so they DON'T duplicate the fetches above.
    final customerStream = customerRepo.watchCustomerById(arg);
    final outstandingStream = customerRepo.watchCustomerOutstanding(arg, skipInitialFetch: true);
    final timelineStream = customerRepo.watchCustomerTimeline(arg, skipInitialFetch: true);

    final customerSub = customerStream.listen((c) {
      if (!_isDisposed && c != null && state.hasValue) {
        state = AsyncValue.data(CustomerDetailData(
          customer: c,
          outstanding: state.value!.outstanding,
          timeline: state.value!.timeline,
        ));
      }
    });

    final outstandingSub = outstandingStream.listen((o) {
      if (!_isDisposed && state.hasValue) {
        state = AsyncValue.data(CustomerDetailData(
          customer: state.value!.customer,
          outstanding: o,
          timeline: state.value!.timeline,
        ));
      }
    });

    final timelineSub = timelineStream.listen((t) {
      if (!_isDisposed && state.hasValue) {
        state = AsyncValue.data(CustomerDetailData(
          customer: state.value!.customer,
          outstanding: state.value!.outstanding,
          timeline: t,
        ));
      }
    });

    ref.onDispose(() {
      _isDisposed = true;
      customerSub.cancel();
      outstandingSub.cancel();
      timelineSub.cancel();
    });

    return CustomerDetailData(
      customer: customer,
      outstanding: outstanding,
      timeline: timeline,
    );
  }

  Future<void> updatePhone(String newPhone) async {
    final customerRepo = ref.read(customerRepositoryProvider);
    await customerRepo.updateCustomerProfile(arg, phone: newPhone);
  }

  Future<void> addNominee(String name, String phone, String relation) async {
    final customerRepo = ref.read(customerRepositoryProvider);
    await customerRepo.addNominee(arg, name, phone, relation);
  }

  Future<void> addProof(String proofType, String imageUrl) async {
    final customerRepo = ref.read(customerRepositoryProvider);
    await customerRepo.addProofImage(arg, proofType, imageUrl);
  }
}
