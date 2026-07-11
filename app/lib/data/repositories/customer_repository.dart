import '../models/customer.dart';
import '../models/outstanding.dart';
import '../models/activity.dart';

abstract class CustomerRepository {
  Stream<List<Customer>> watchCustomersByArea(String areaId);
  Future<List<Customer>> getCustomersByArea(String areaId);
  Future<Customer?> getCustomerById(String id);
  Stream<Customer?> watchCustomerById(String id);
  
  Stream<Outstanding> watchCustomerOutstanding(String customerId);
  Future<Outstanding> getCustomerOutstanding(String customerId);
  
  Stream<List<Activity>> watchCustomerTimeline(String customerId);
  Future<List<Activity>> getCustomerTimeline(String customerId);

  Future<void> updateCustomerProfile(String id, {String? phone, String? photoUrl, String? locationUrl});
  Future<void> addNominee(String customerId, String name, String phone, String relation);
  Future<void> addProofImage(String customerId, String proofType, String imageUrl);
}
