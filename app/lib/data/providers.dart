import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repositories/customer_repository.dart';
import 'repositories/collection_repository.dart';
import 'repositories/route_repository.dart';
import 'repositories/sale_repository.dart';
import 'repositories/product_repository.dart';
import 'mock/mock_repository.dart';
import 'models/product.dart';
import 'models/customer.dart';
import 'models/collection.dart';
import 'models/sale.dart';
import 'models/outstanding.dart';

/// Customer Repository Provider
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return ref.watch(mockRepositoryProvider);
});

/// Collection Repository Provider
final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  return ref.watch(mockRepositoryProvider);
});

/// Route Repository Provider
final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return ref.watch(mockRepositoryProvider);
});

/// Sale Repository Provider
final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return ref.watch(mockRepositoryProvider);
});

/// Product Repository Provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ref.watch(mockRepositoryProvider);
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
final customerOutstandingProvider = StreamProvider.family<Outstanding, String>((ref, customerId) {
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
