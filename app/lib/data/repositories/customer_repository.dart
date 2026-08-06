import '../models/customer.dart';
import '../models/outstanding.dart';
import '../models/activity.dart';
import '../models/location.dart';
import '../models/nominee.dart';
import '../models/id_proof.dart';

abstract class CustomerRepository {
  Stream<List<Customer>> watchAllCustomers();
  Future<List<Customer>> getAllCustomers();
  Stream<List<Customer>> watchCustomersByArea(String areaId);
  Future<List<Customer>> getCustomersByArea(String areaId);
  Future<Customer?> getCustomerById(String id);
  Stream<Customer?> watchCustomerById(String id);
  
  Stream<Outstanding> watchCustomerOutstanding(String customerId, {bool skipInitialFetch = false});
  Future<Outstanding> getCustomerOutstanding(String customerId);
  
  Stream<List<Activity>> watchCustomerTimeline(String customerId, {bool skipInitialFetch = false});
  Future<List<Activity>> getCustomerTimeline(String customerId);

  Future<void> updateCustomerProfile(String id, {String? phone, String? profileUrl, String? locationUrl});
  Future<void> addNominee(String customerId, String name, String phone, String relation);
  Future<void> addProofImage(String customerId, String proofType, String imageUrl);
  
  Future<Customer> addCustomer({
    required String name,
    required String phone,
    required String address,
    required String weekdayId,
    required String placeId,
    required String areaId,
    String? alternatePhone,
    String? landmark,
    String? notes,
    String? dob,
    String? occupation,
    int openingBalance = 0,
    List<Nominee>? nominees,
    List<IdProof>? idProofs,
    Location? location,
    String? profileUrl,
  });

  Future<void> updateCustomer(Customer customer);
  Future<void> undoCustomer(String customerId);
}
