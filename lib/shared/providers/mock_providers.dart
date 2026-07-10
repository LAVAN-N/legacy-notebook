import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/weekday_model.dart';
import '../models/place_model.dart';
import '../models/area_model.dart';
import '../models/customer_model.dart';
import '../models/activity_model.dart';

/// Load and parse mock data from JSON files.
class MockDataService {
  static Future<String> _loadAsset(String path) {
    return rootBundle.loadString(path);
  }

  static Future<UserModel> loadUser() async {
    final json = await _loadAsset('assets/mock_data/users.json');
    final data = jsonDecode(json);
    return UserModel.fromJson(data);
  }

  static Future<List<WeekdayModel>> loadWeekdays() async {
    final json = await _loadAsset('assets/mock_data/weekdays.json');
    final data = jsonDecode(json) as List;
    return data.map((e) => WeekdayModel.fromJson(e)).toList();
  }

  static Future<List<PlaceModel>> loadPlaces() async {
    final json = await _loadAsset('assets/mock_data/places.json');
    final data = jsonDecode(json) as List;
    return data.map((e) => PlaceModel.fromJson(e)).toList();
  }

  static Future<List<AreaModel>> loadAreas() async {
    final json = await _loadAsset('assets/mock_data/areas.json');
    final data = jsonDecode(json) as List;
    return data.map((e) => AreaModel.fromJson(e)).toList();
  }

  static Future<List<CustomerModel>> loadCustomers() async {
    final json = await _loadAsset('assets/mock_data/customers.json');
    final data = jsonDecode(json) as List;
    return data.map((e) => CustomerModel.fromJson(e)).toList();
  }

  static Future<List<ActivityModel>> loadActivities() async {
    final json = await _loadAsset('assets/mock_data/activities.json');
    final data = jsonDecode(json) as List;
    return data.map((e) => ActivityModel.fromJson(e)).toList();
  }
}

// Riverpod Providers

/// Current logged-in user.
final mockUserProvider = FutureProvider<UserModel>((ref) {
  return MockDataService.loadUser();
});

/// All available weekdays.
final mockWeekdaysProvider = FutureProvider<List<WeekdayModel>>((ref) {
  return MockDataService.loadWeekdays();
});

/// All available places (filtered by weekday in consumers).
final mockPlacesProvider = FutureProvider<List<PlaceModel>>((ref) {
  return MockDataService.loadPlaces();
});

/// All available areas (filtered by place in consumers).
final mockAreasProvider = FutureProvider<List<AreaModel>>((ref) {
  return MockDataService.loadAreas();
});

/// All available customers (filtered by area in consumers).
final mockCustomersProvider = FutureProvider<List<CustomerModel>>((ref) {
  return MockDataService.loadCustomers();
});

/// All available activities (filtered by customer in consumers).
final mockActivitiesProvider = FutureProvider<List<ActivityModel>>((ref) {
  return MockDataService.loadActivities();
});

/// Get places for a specific weekday.
final mockPlacesByWeekdayProvider =
    FutureProvider.family<List<PlaceModel>, String>((ref, weekdayId) async {
  final places = await ref.watch(mockPlacesProvider.future);
  return places.where((p) => p.weekdayId == weekdayId).toList();
});

/// Get areas for a specific place.
final mockAreasByPlaceProvider =
    FutureProvider.family<List<AreaModel>, String>((ref, placeId) async {
  final areas = await ref.watch(mockAreasProvider.future);
  return areas.where((a) => a.placeId == placeId).toList();
});

/// Get customers for a specific area.
final mockCustomersByAreaProvider =
    FutureProvider.family<List<CustomerModel>, String>((ref, areaId) async {
  final customers = await ref.watch(mockCustomersProvider.future);
  return customers.where((c) => c.areaId == areaId).toList();
});

/// Get a specific customer by ID.
final mockCustomerByIdProvider =
    FutureProvider.family<CustomerModel?, String>((ref, customerId) async {
  final customers = await ref.watch(mockCustomersProvider.future);
  return customers.cast<CustomerModel?>().firstWhere(
        (c) => c?.id == customerId,
        orElse: () => null,
      );
});

/// Get activities for a specific customer.
final mockActivitiesByCustomerProvider =
    FutureProvider.family<List<ActivityModel>, String>((ref, customerId) async {
  final activities = await ref.watch(mockActivitiesProvider.future);
  return activities.where((a) => a.customerId == customerId).toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
});

/// Get today's weekday (Thursday for demo).
final todayWeekdayIdProvider = Provider<String>((ref) {
  return 'weekday_4'; // Thursday
});

/// Get today's expected and collected amounts.
final todaysSummaryProvider = FutureProvider<Map<String, int>>((ref) async {
  final todayId = ref.watch(todayWeekdayIdProvider);
  final places = await ref.watch(mockPlacesByWeekdayProvider(todayId).future);

  int totalExpected = 0;
  int totalCollected = 0;

  for (final place in places) {
    totalExpected += place.expectedAmount;
    totalCollected += place.collectedAmount;
  }

  return {
    'expected': totalExpected,
    'collected': totalCollected,
  };
});

/// Get recent activities (last 5).
final recentActivitiesProvider = FutureProvider<List<ActivityModel>>((ref) async {
  final activities = await ref.watch(mockActivitiesProvider.future);
  activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return activities.take(5).toList();
});
