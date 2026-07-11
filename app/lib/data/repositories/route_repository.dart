import '../models/weekday.dart';
import '../models/place.dart';
import '../models/area.dart';

abstract class RouteRepository {
  Future<List<Weekday>> getWeekdays();
  Stream<List<Weekday>> watchWeekdays();
  
  Future<List<Place>> getPlacesByWeekday(String weekdayId);
  Stream<List<Place>> watchPlacesByWeekday(String weekdayId);
  
  Future<List<Area>> getAreasByPlace(String placeId);
  Stream<List<Area>> watchAreasByPlace(String placeId);

  Future<int> getCustomerCountForWeekday(String weekdayId);
  Future<int> getCustomerCountForPlace(String placeId);
  Future<int> getCustomerCountForArea(String areaId);

  Future<int> getExpectedCollectionForWeekday(String weekdayId);
  Future<int> getExpectedCollectionForPlace(String placeId);
  Future<int> getExpectedCollectionForArea(String areaId);

  Future<int> getActualCollectionForWeekday(String weekdayId);
  Future<int> getActualCollectionForPlace(String placeId);
  Future<int> getActualCollectionForArea(String areaId);
}
