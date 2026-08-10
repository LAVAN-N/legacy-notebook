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

    // Fetch all 3 snapshots in parallel — no streams, no channels, no cleanup races.
    // AutoDispose re-runs build() with fresh data on every navigation to this screen.
    final results = await Future.wait([
      customerRepo.getCustomerById(arg),
      customerRepo.getCustomerOutstanding(arg),
      customerRepo.getCustomerTimeline(arg),
    ]);

    final customer = results[0] as Customer?;
    if (customer == null) throw Exception('Customer not found');

    return CustomerDetailData(
      customer: customer,
      outstanding: results[1] as Outstanding,
      timeline: results[2] as List<Activity>,
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
