import '../models/sale.dart';
import '../models/sale_item.dart';

abstract class SaleRepository {
  Future<void> saveSale({
    required String customerId,
    required List<Map<String, dynamic>> items, // Each contains: 'productId', 'quantity', 'unitPrice'
    required int advanceAmount,
    required String soldBy,
    String? remarks,
  });

  Future<void> undoSale(String saleId);
}
