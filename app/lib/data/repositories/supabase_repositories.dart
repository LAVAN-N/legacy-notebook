import '../models/customer.dart';
import '../models/outstanding.dart';
import '../models/activity.dart';
import '../models/weekday.dart';
import '../models/place.dart';
import '../models/area.dart';
import '../models/collection.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/location.dart';
import '../models/nominee.dart';
import '../models/id_proof.dart';
import 'customer_repository.dart';
import 'route_repository.dart';
import 'collection_repository.dart';
import 'sale_repository.dart';
import 'product_repository.dart';

class SupabaseCustomerRepository implements CustomerRepository {
  @override
  Stream<List<Customer>> watchAllCustomers() => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<List<Customer>> getAllCustomers() => throw UnimplementedError('wire in follow-up skill');

  @override
  Stream<List<Customer>> watchCustomersByArea(String areaId) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<List<Customer>> getCustomersByArea(String areaId) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<Customer?> getCustomerById(String id) => throw UnimplementedError('wire in follow-up skill');

  @override
  Stream<Customer?> watchCustomerById(String id) => throw UnimplementedError('wire in follow-up skill');

  @override
  Stream<Outstanding> watchCustomerOutstanding(String customerId) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<Outstanding> getCustomerOutstanding(String customerId) => throw UnimplementedError('wire in follow-up skill');

  @override
  Stream<List<Activity>> watchCustomerTimeline(String customerId) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<List<Activity>> getCustomerTimeline(String customerId) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<void> updateCustomerProfile(String id, {String? phone, String? photoUrl, String? locationUrl}) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<void> addNominee(String customerId, String name, String phone, String relation) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<void> addProofImage(String customerId, String proofType, String imageUrl) => throw UnimplementedError('wire in follow-up skill');

  @override
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
  }) async {
    // TODO: Implement Supabase write
    throw UnimplementedError('wire in follow-up skill');
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    // TODO: Implement Supabase update
    throw UnimplementedError('wire in follow-up skill');
  }

  @override
  Future<void> undoCustomer(String customerId) async {
    // TODO: Implement Supabase undo
    throw UnimplementedError('wire in follow-up skill');
  }
}

class SupabaseRouteRepository implements RouteRepository {
  @override
  Future<List<Weekday>> getWeekdays() => throw UnimplementedError('wire in follow-up skill');

  @override
  Stream<List<Weekday>> watchWeekdays() => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<List<Place>> getPlacesByWeekday(String weekdayId) => throw UnimplementedError('wire in follow-up skill');

  @override
  Stream<List<Place>> watchPlacesByWeekday(String weekdayId) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<List<Area>> getAreasByPlace(String placeId) => throw UnimplementedError('wire in follow-up skill');

  @override
  Stream<List<Area>> watchAreasByPlace(String placeId) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<int> getCustomerCountForWeekday(String weekdayId) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<int> getCustomerCountForPlace(String placeId) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<int> getCustomerCountForArea(String areaId) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<int> getExpectedCollectionForWeekday(String weekdayId) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<int> getExpectedCollectionForPlace(String placeId) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<int> getExpectedCollectionForArea(String areaId) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<int> getActualCollectionForWeekday(String weekdayId) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<int> getActualCollectionForPlace(String placeId) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<int> getActualCollectionForArea(String areaId) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<Place> addPlace({
    required String weekdayId,
    required String name,
  }) async {
    // TODO: Implement Supabase write
    throw UnimplementedError('wire in follow-up skill');
  }

  @override
  Future<Area> addArea({
    required String placeId,
    required String name,
  }) async {
    // TODO: Implement Supabase write
    throw UnimplementedError('wire in follow-up skill');
  }
}

class SupabaseCollectionRepository implements CollectionRepository {
  @override
  Stream<List<Collection>> watchAllCollections() => throw UnimplementedError('wire in follow-up skill');

  @override
  Stream<List<Collection>> watchCollectionsForCustomerToday(String customerId) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<List<Collection>> getCollectionsForCustomerToday(String customerId) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<void> saveCollection({
    required String customerId,
    required String status,
    required int amount,
    String? reason,
    required String collectedBy,
  }) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<void> undoCollection(String collectionId) => throw UnimplementedError('wire in follow-up skill');
}

class SupabaseSaleRepository implements SaleRepository {
  @override
  Stream<List<Sale>> watchAllSales() => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<void> saveSale({
    required String customerId,
    required List<Map<String, dynamic>> items,
    required int advanceAmount,
    required String soldBy,
    int discount = 0,
    String? remarks,
  }) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<void> undoSale(String saleId) => throw UnimplementedError('wire in follow-up skill');
}

class SupabaseProductRepository implements ProductRepository {
  @override
  Future<List<Product>> getProducts() => throw UnimplementedError('wire in follow-up skill');

  @override
  Stream<List<Product>> watchProducts() => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<Product?> getProductById(String id) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<Product> addProduct({
    required String name,
    required String brand,
    required String sku,
    required int costPrice,
    required int sellingPrice,
    required int mrp,
    required int stock,
    required String categoryId,
    required int minimumStock,
    String? description,
    String? imageUrl,
  }) => throw UnimplementedError('wire in follow-up skill');

  @override
  Future<void> updateProduct(Product product) => throw UnimplementedError('wire in follow-up skill');
}
