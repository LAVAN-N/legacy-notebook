import '../models/collection.dart';

abstract class CollectionRepository {
  Stream<List<Collection>> watchAllCollections();
  Stream<List<Collection>> watchCollectionsForCustomerToday(String customerId);
  Future<List<Collection>> getCollectionsForCustomerToday(String customerId);
  
  Future<void> saveCollection({
    required String customerId,
    required String status,
    required double amount,
    String? reason,
    required String collectedBy,
    DateTime? customDate,
  });

  Future<void> undoCollection(String collectionId);
}
