import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/outstanding.dart';
import '../../../data/models/activity.dart';
import '../../../data/models/sale_item.dart';
import '../../../data/models/product.dart';
import '../../../data/models/sale.dart';
import '../../../data/providers.dart';

class PurchasedProductItem {
  const PurchasedProductItem({
    required this.saleItemId,
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.status, // 'purchased', 'returned', 'settled'
    required this.purchaseDate,
    required this.collectedAmount,
  });

  final String saleItemId;
  final String productId;
  final String productName;
  final String productSku;
  final int quantity;
  final int unitPrice;
  final int totalPrice;
  final String status;
  final DateTime purchaseDate;
  final int collectedAmount;
}

class CustomerDetailData {
  const CustomerDetailData({
    required this.customer,
    required this.outstanding,
    required this.timeline,
    required this.purchasedProducts,
  });

  final Customer customer;
  final Outstanding outstanding;
  final List<Activity> timeline;
  final List<PurchasedProductItem> purchasedProducts;
}

final customerDetailControllerProvider = AsyncNotifierProvider.autoDispose.family<CustomerDetailNotifier, CustomerDetailData, String>((arg) {
  return CustomerDetailNotifier(arg);
});

class CustomerDetailNotifier extends AsyncNotifier<CustomerDetailData> {
  CustomerDetailNotifier(this.arg);
  final String arg;

  @override
  Future<CustomerDetailData> build() async {
    final customerRepo = ref.read(customerRepositoryProvider);
    final saleRepo = ref.read(saleRepositoryProvider);
    final productRepo = ref.read(productRepositoryProvider);

    // Fetch all required data snapshots
    final results = await Future.wait([
      customerRepo.getCustomerById(arg),
      customerRepo.getCustomerOutstanding(arg),
      customerRepo.getCustomerTimeline(arg),
      saleRepo.getSaleItemsForCustomer(arg),
      productRepo.getProducts(),
      saleRepo.getAllSales(),
    ]);

    final customer = results[0] as Customer?;
    if (customer == null) throw Exception('Customer not found');

    final outstanding = results[1] as Outstanding;
    final timeline = results[2] as List<Activity>;
    final saleItems = results[3] as List<SaleItem>;
    final products = results[4] as List<Product>;
    final allSales = results[5] as List<Sale>;

    // Filter sales of this customer and sort chronologically (oldest to newest)
    final customerSales = allSales.where((s) => s.customerId == arg).toList()
      ..sort((a, b) => a.saleDatetime.compareTo(b.saleDatetime));

    final Map<String, DateTime> saleDates = {
      for (final s in customerSales) s.id: s.saleDatetime
    };

    // Filter active items and sort chronologically based on parent sale datetime
    final activeSaleItems = saleItems.where((si) => si.status != 'returned').toList()
      ..sort((a, b) => (saleDates[a.saleId] ?? DateTime.now()).compareTo(saleDates[b.saleId] ?? DateTime.now()));

    // Total paid = advances of current sales + collections
    final int totalPaid = customerSales.fold<int>(0, (sum, s) => sum + s.advanceAmount) + outstanding.totalCollected;

    // Chronologically allocate totalPaid to active items
    final Map<String, int> allocatedCollectedAmount = {};
    int remainingPaid = totalPaid;
    for (final item in activeSaleItems) {
      final int allocated = remainingPaid < item.totalPrice ? remainingPaid : item.totalPrice;
      allocatedCollectedAmount[item.id] = allocated;
      remainingPaid -= allocated;
    }

    // Map to PurchasedProductItem
    final List<PurchasedProductItem> purchasedProducts = [];
    for (final item in saleItems) {
      final product = products.firstWhere(
        (p) => p.id == item.productId,
        orElse: () => Product(
          id: item.productId,
          sku: 'unknown',
          name: 'Unknown Product',
          brand: 'unknown',
          categoryId: 'unknown',
          minimumStock: 0,
          sellingPrice: 0,
          costPrice: 0,
          mrp: 0,
          stock: 0,
        ),
      );
      final parentSale = customerSales.firstWhere(
        (s) => s.id == item.saleId,
        orElse: () => Sale(
          id: item.saleId,
          customerId: arg,
          saleDatetime: DateTime.now(),
          saleType: 'CREDIT',
          totalAmount: 0,
          advanceAmount: 0,
          financedAmount: 0,
          soldBy: 'system',
        ),
      );

      final collected = item.collectedAmount > 0
          ? item.collectedAmount
          : (allocatedCollectedAmount[item.id] ?? 0);

      purchasedProducts.add(PurchasedProductItem(
        saleItemId: item.id,
        productId: item.productId,
        productName: product.name,
        productSku: product.sku,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        totalPrice: item.totalPrice,
        status: item.status,
        purchaseDate: parentSale.saleDatetime,
        collectedAmount: collected,
      ));
    }

    // Sort display purchased products by date descending (newest first)
    purchasedProducts.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));

    return CustomerDetailData(
      customer: customer,
      outstanding: outstanding,
      timeline: timeline,
      purchasedProducts: purchasedProducts,
    );
  }

  Future<void> updatePhone(String newPhone) async {
    final customerRepo = ref.read(customerRepositoryProvider);
    await customerRepo.updateCustomerProfile(arg, phone: newPhone);
  }

  Future<void> addNominee(String name, String phone, String relation) async {
    final customerRepo = ref.read(customerRepositoryProvider);
    await customerRepo.addNominee(arg, name, phone, relation);
  }

  Future<void> addProof(String proofType, String imageUrl) async {
    final customerRepo = ref.read(customerRepositoryProvider);
    await customerRepo.addProofImage(arg, proofType, imageUrl);
  }

  Future<void> returnProduct(
    String saleItemId,
    int collectedAmount,
    String processedBy, {
    required bool tallyOut,
    String? tallySaleItemId,
    String? tallyProductName,
    int? tallyAmount,
  }) async {
    final saleRepo = ref.read(saleRepositoryProvider);
    await saleRepo.returnProduct(
      saleItemId: saleItemId,
      collectedAmount: collectedAmount,
      processedBy: processedBy,
      tallyOut: tallyOut,
      tallySaleItemId: tallySaleItemId,
      tallyProductName: tallyProductName,
      tallyAmount: tallyAmount,
    );
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> settleProduct(String saleItemId) async {
    final saleRepo = ref.read(saleRepositoryProvider);
    await saleRepo.settleProduct(saleItemId);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
