import '../models/place.dart';
import '../models/area.dart';
import '../models/category.dart';

abstract class ConfigRepository {
  // Places
  Future<List<Place>> getPlaces();
  Stream<List<Place>> watchPlaces();
  Future<void> savePlaces(List<Place> places);
  
  // Areas
  Future<List<Area>> getAreas();
  Stream<List<Area>> watchAreas();
  Future<void> saveAreas(List<Area> areas);
  
  // Categories
  Future<List<Category>> getCategories();
  Stream<List<Category>> watchCategories();
  Future<void> saveCategories(List<Category> categories);
  
  // Brands
  Future<List<String>> getBrands();
  Stream<List<String>> watchBrands();
  Future<void> saveBrands(List<String> brands);

  // Proof Types
  Future<List<String>> getProofTypes();
  Stream<List<String>> watchProofTypes();
  Future<void> saveProofTypes(List<String> proofTypes);
}
