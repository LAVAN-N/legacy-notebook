import '../models/sale.dart';

abstract class SaleRepository {
  Stream<List<Sale>> watchAllSales();
  Future<void> saveSale({
    required String customerId,
    required List<Map<String, dynamic>> items, // Each contains: 'productId', 'quantity', 'unitPrice'
    required int advanceAmount,
    required String soldBy,
    int discount = 0,
    int creditCharge = 0,
    String? remarks,
  });

  Future<void> undoSale(String saleId);
}
