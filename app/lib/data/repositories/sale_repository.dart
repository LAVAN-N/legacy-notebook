import '../models/sale.dart';
import '../models/sale_item.dart';

abstract class SaleRepository {
  Stream<List<Sale>> watchAllSales();
  Future<List<Sale>> getAllSales();
  Future<void> saveSale({
    required String customerId,
    required List<Map<String, dynamic>> items, // Each contains: 'productId', 'quantity', 'unitPrice'
    required int advanceAmount,
    required String soldBy,
    int discount = 0,
    int creditCharge = 0,
    String? remarks,
    DateTime? customDate,
    int? lendAmount,
  });

  Future<void> undoSale(String saleId);

  Future<List<SaleItem>> getSaleItemsForCustomer(String customerId);
  Future<void> returnProduct({
    required String saleItemId,
    required int collectedAmount,
    required String processedBy,
  });
  Future<void> settleProduct(String saleItemId);
}
