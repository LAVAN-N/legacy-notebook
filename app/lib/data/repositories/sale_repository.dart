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
    int appliedCredit = 0,
  });

  Future<void> undoSale(String saleId);

  Future<List<SaleItem>> getSaleItemsForCustomer(String customerId);
  Future<void> returnProduct({
    required String saleItemId,
    required int collectedAmount,
    required String processedBy,
    required bool tallyOut,
    String? tallySaleItemId,
    String? tallyProductName,
    int? tallyAmount,
  });
  Future<void> settleProduct(String saleItemId);
}
