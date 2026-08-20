import '../models/collection.dart';

abstract class CollectionRepository {
  Stream<List<Collection>> watchAllCollections();
  Future<List<Collection>> getAllCollections();
  Stream<List<Collection>> watchCollectionsForCustomerToday(String customerId);
  Future<List<Collection>> getCollectionsForCustomerToday(String customerId);
  
  Future<void> saveCollection({
    required String customerId,
    required String status,
    required double amount,
    String? reason,
    required String collectedBy,
    DateTime? customDate,
    Map<String, int>? allocations,
  });

  Future<void> undoCollection(String collectionId);
}
