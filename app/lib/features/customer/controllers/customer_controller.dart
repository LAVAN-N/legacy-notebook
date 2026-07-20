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
  @override
  Future<CustomerDetailData> build(String arg) async {
    final customerRepo = ref.read(customerRepositoryProvider);

    // Watch values so the UI rebuilds immediately when underlying data mutates (e.g. from collections/sales)
    final customerStream = customerRepo.watchCustomerById(arg);
    final outstandingStream = customerRepo.watchCustomerOutstanding(arg);
    final timelineStream = customerRepo.watchCustomerTimeline(arg);

    // Let's grab the current snapshot values asynchronously
    final customer = await customerRepo.getCustomerById(arg);
    if (customer == null) throw Exception('Customer not found');

    final outstanding = await customerRepo.getCustomerOutstanding(arg);
    final timeline = await customerRepo.getCustomerTimeline(arg);

    // Listen to changes to rebuild state
    customerStream.listen((c) {
      if (c != null && state.hasValue) {
        state = AsyncValue.data(CustomerDetailData(
          customer: c,
          outstanding: state.value!.outstanding,
          timeline: state.value!.timeline,
        ));
      }
    });

    outstandingStream.listen((o) {
      if (state.hasValue) {
        state = AsyncValue.data(CustomerDetailData(
          customer: state.value!.customer,
          outstanding: o,
          timeline: state.value!.timeline,
        ));
      }
    });

    timelineStream.listen((t) {
      if (state.hasValue) {
        state = AsyncValue.data(CustomerDetailData(
          customer: state.value!.customer,
          outstanding: state.value!.outstanding,
          timeline: t,
        ));
      }
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
