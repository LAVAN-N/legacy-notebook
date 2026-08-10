import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repositories/customer_repository.dart';
import 'repositories/collection_repository.dart';
import 'repositories/route_repository.dart';
import 'repositories/sale_repository.dart';
import 'repositories/product_repository.dart';
import 'mock/mock_repository.dart';
import 'repositories/local_sqlite_repositories.dart';
import 'repositories/supabase_repositories.dart';
import 'models/product.dart';
import 'models/customer.dart';
import 'models/collection.dart';
import 'models/sale.dart';
import 'models/outstanding.dart';
import 'repositories/config_repository.dart';
import 'models/category.dart';
import 'models/place.dart';
import 'models/area.dart';
import 'models/weekday.dart';

/// Local SQLite Repository Providers
final localSqliteCustomerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return LocalSqliteCustomerRepository();
});

final localSqliteCollectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  return LocalSqliteCollectionRepository();
});

final localSqliteRouteRepositoryProvider = Provider<RouteRepository>((ref) {
  return LocalSqliteRouteRepository();
});

final localSqliteSaleRepositoryProvider = Provider<SaleRepository>((ref) {
  return LocalSqliteSaleRepository();
});

final localSqliteProductRepositoryProvider = Provider<ProductRepository>((ref) {
  return LocalSqliteProductRepository();
});

final localSqliteConfigRepositoryProvider = Provider<ConfigRepository>((ref) {
  return LocalSqliteConfigRepository();
});

/// Set to true to read/write to your live Supabase DB,
/// or false to use local SQLite.
const bool useSupabaseBackend = true;

/// Customer Repository Provider
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return useSupabaseBackend 
      ? SupabaseCustomerRepository() 
      : ref.watch(localSqliteCustomerRepositoryProvider);
});

/// Collection Repository Provider
final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  return useSupabaseBackend 
      ? SupabaseCollectionRepository() 
      : ref.watch(localSqliteCollectionRepositoryProvider);
});

/// Route Repository Provider
final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return useSupabaseBackend 
      ? SupabaseRouteRepository() 
      : ref.watch(localSqliteRouteRepositoryProvider);
});

/// Sale Repository Provider
final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return useSupabaseBackend 
      ? SupabaseSaleRepository() 
      : ref.watch(localSqliteSaleRepositoryProvider);
});

/// Product Repository Provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return useSupabaseBackend 
      ? SupabaseProductRepository() 
      : ref.watch(localSqliteProductRepositoryProvider);
});

/// Config Repository Provider
final configRepositoryProvider = Provider<ConfigRepository>((ref) {
  return useSupabaseBackend
      ? SupabaseConfigRepository()
      : ref.watch(localSqliteConfigRepositoryProvider);
});

/// Products Stream Provider
final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.watchProducts();
});

/// Customers Stream Provider
final customersStreamProvider = StreamProvider<List<Customer>>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.watchAllCustomers();
});

/// Customer Outstanding Stream Provider
final customerOutstandingProvider = StreamProvider.autoDispose.family<Outstanding, String>((ref, customerId) {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.watchCustomerOutstanding(customerId);
});

/// Collections Stream Provider
final collectionsStreamProvider = StreamProvider<List<Collection>>((ref) {
  final repo = ref.watch(collectionRepositoryProvider);
  return repo.watchAllCollections();
});

/// Sales Stream Provider
final salesStreamProvider = StreamProvider<List<Sale>>((ref) {
  final repo = ref.watch(saleRepositoryProvider);
  return repo.watchAllSales();
});

/// Mock Repository Provider (for development/testing)
final mockRepositoryProvider = Provider<MockRepository>((ref) {
  return MockRepository(ref);
});

/// Categories Stream Provider
final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final repo = ref.watch(configRepositoryProvider);
  return repo.watchCategories();
});

/// Brands Stream Provider
final brandsStreamProvider = StreamProvider<List<String>>((ref) {
  final repo = ref.watch(configRepositoryProvider);
  return repo.watchBrands();
});

/// Proof Types Stream Provider
final proofTypesStreamProvider = StreamProvider<List<String>>((ref) {
  final repo = ref.watch(configRepositoryProvider);
  return repo.watchProofTypes();
});

/// Places Stream Provider
final placesStreamProvider = StreamProvider<List<Place>>((ref) {
  final repo = ref.watch(configRepositoryProvider);
  return repo.watchPlaces();
});

/// Areas Stream Provider
final areasStreamProvider = StreamProvider<List<Area>>((ref) {
  final repo = ref.watch(configRepositoryProvider);
  return repo.watchAreas();
});

/// Weekdays Stream Provider
final weekdaysStreamProvider = StreamProvider<List<Weekday>>((ref) {
  final repo = ref.watch(routeRepositoryProvider);
  return repo.watchWeekdays();
});

