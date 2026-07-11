class Routes {
  Routes._();

  static const String dashboard = '/';
  static const String weekdayPattern = '/weekday/:day';
  static const String placePattern = '/place/:placeId';
  static const String areaPattern = '/area/:areaId';
  static const String customerPattern = '/customer/:customerId';
  static const String collectPattern = '/customer/:customerId/collect';
  static const String salePattern = '/customer/:customerId/sale';

  static String weekday(String day) => '/weekday/$day';
  static String place(String placeId) => '/place/$placeId';
  static String area(String areaId) => '/area/$areaId';
  static String customer(String customerId) => '/customer/$customerId';
  static String collect(String customerId) => '/customer/$customerId/collect';
  static String sale(String customerId) => '/customer/$customerId/sale';
}
