import 'package:endimata/common/AppData/data/models/photo_model.dart';

abstract class AppDataApiService {
  Future<List<String>> getHumanPhotos();
  Future<List<PhotoModel>> getCatalogItems();
  Future<List<PhotoModel>> getWardrobeItems();
  Future<void> addHumanPhoto(String fileBase64, String userName);
  Future<void> addClothingItem(
    String fileBase64,
    String userName,
    String category,
    String subcategory,
    String subSubcategory,
  );
  Future<void> clearData();
  Future<void> deletePhoto(String id, String type);
}
