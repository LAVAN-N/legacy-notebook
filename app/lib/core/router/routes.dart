class Routes {
  Routes._();

  static const String splash = '/splash';
  static const String dashboard = '/';
  static const String newClient = '/customer/new';
  static const String weekdayPattern = '/weekday/:day';
  static const String placePattern = '/weekday/:day/place/:placeId';
  static const String areaPattern = '/weekday/:day/place/:placeId/area/:areaId';
  static const String customerPattern = '/weekday/:day/place/:placeId/area/:areaId/customer/:customerId';
  static const String collectPattern = '/weekday/:day/place/:placeId/area/:areaId/customer/:customerId/collect';
  static const String salePattern = '/weekday/:day/place/:placeId/area/:areaId/customer/:customerId/sale';
  
  // Inventory routes
  static const String inventory = '/inventory';
  static const String inventoryCategoryPattern = '/inventory/:categoryId';
  static const String inventoryProductPattern = '/inventory/:categoryId/:productId';

  static String weekday(String day) => '/weekday/$day';
  static String place(String day, String placeId) => '/weekday/$day/place/$placeId';
  static String area(String day, String placeId, String areaId) => '/weekday/$day/place/$placeId/area/$areaId';
  static String customer(String day, String placeId, String areaId, String customerId) => '/weekday/$day/place/$placeId/area/$areaId/customer/$customerId';
  static String collect(String day, String placeId, String areaId, String customerId) => '/weekday/$day/place/$placeId/area/$areaId/customer/$customerId/collect';
  static String sale(String day, String placeId, String areaId, String customerId) => '/weekday/$day/place/$placeId/area/$areaId/customer/$customerId/sale';
  
  static String inventoryCategory(String categoryId) => '/inventory/$categoryId';
  static String inventoryProduct(String categoryId, String productId) => '/inventory/$categoryId/$productId';
}
