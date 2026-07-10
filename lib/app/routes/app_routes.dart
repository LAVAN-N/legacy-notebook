/// Route names as constants for type-safe navigation.
class AppRoutes {
  static const splash = '/';
  static const dashboard = '/dashboard';
  static const weekdays = '/routes/weekdays';
  static const places = '/routes/weekdays/:weekdayId/places';
  static const areas = '/routes/weekdays/:weekdayId/places/:placeId/areas';
  static const customers =
      '/routes/weekdays/:weekdayId/places/:placeId/areas/:areaId/customers';
  static const customerDetails =
      '/routes/weekdays/:weekdayId/places/:placeId/areas/:areaId/customers/:customerId';
  static const search = '/search';
}
