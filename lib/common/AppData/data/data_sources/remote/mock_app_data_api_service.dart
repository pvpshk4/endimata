import 'package:hive/hive.dart';
import 'package:endimata/common/AppData/data/data_sources/remote/app_data_api_service.dart';
import 'package:endimata/common/AppData/data/models/deleted_photo_model.dart';
import 'package:endimata/common/AppData/data/models/photo_model.dart';

class MockAppDataApiService implements AppDataApiService {
  final Box<String> _humanPhotosBox;
  final Box<PhotoModel> _catalogItemsBox;
  final Box<PhotoModel> _wardrobeItemsBox;
  final Box<DeletedPhotoModel> _deletedPhotosBox;

  MockAppDataApiService(
    this._humanPhotosBox,
    this._catalogItemsBox,
    this._wardrobeItemsBox,
    this._deletedPhotosBox,
  );

  @override
  Future<List<String>> getHumanPhotos() async {
    return _humanPhotosBox.values.toList();
  }

  @override
  Future<void> addHumanPhoto(String fileBase64, String userName) async {
    await _humanPhotosBox.add(fileBase64);
  }

  @override
  Future<List<PhotoModel>> getCatalogItems() async {
    final items = _catalogItemsBox.values.toList();
    items.sort((a, b) {
      final categoryComparison = a.category.compareTo(b.category);
      if (categoryComparison != 0) return categoryComparison;
      return a.subcategory.compareTo(b.subcategory);
    });
    return items;
  }

  @override
  Future<List<PhotoModel>> getWardrobeItems() async {
    final items = _wardrobeItemsBox.values.toList();
    items.sort((a, b) {
      final categoryComparison = a.category.compareTo(b.category);
      if (categoryComparison != 0) return categoryComparison;
      return a.subcategory.compareTo(b.subcategory);
    });
    return items;
  }

  @override
  Future<void> addClothingItem(
    String fileBase64,
    String userName,
    String category,
    String subcategory,
    String subSubcategory,
  ) async {
    final newItem = PhotoModel(
      user_name: userName,
      image: fileBase64,
      category: category,
      subcategory: subcategory,
      sub_subcategory: subSubcategory,
    );
    await _wardrobeItemsBox.add(newItem);
  }

  @override
  Future<void> clearData() async {
    await _humanPhotosBox.clear();
    await _catalogItemsBox.clear();
    await _wardrobeItemsBox.clear();
    await _deletedPhotosBox.clear();
  }

  @override
  Future<void> deletePhoto(String id, String type) async {
    if (type == 'human') {
      final index = _humanPhotosBox.values.toList().indexWhere(
        (photo) => photo.hashCode.toString() == id,
      );
      if (index != -1) {
        final photo = _humanPhotosBox.getAt(index)!;
        await _humanPhotosBox.deleteAt(index);
        await _deletedPhotosBox.add(
          DeletedPhotoModel.fromHumanPhoto(photo, 'test_user', id),
        );
      }
    } else if (type == 'wardrobe') {
      final index = _wardrobeItemsBox.values.toList().indexWhere(
        (photo) => photo.hashCode.toString() == id,
      );
      if (index != -1) {
        final photo = _wardrobeItemsBox.getAt(index)!;
        await _wardrobeItemsBox.deleteAt(index);
        await _deletedPhotosBox.add(
          DeletedPhotoModel.fromWardrobeItem(photo, id),
        );
      }
    }
  }

  Future<List<DeletedPhotoModel>> getDeletedPhotos() async {
    return _deletedPhotosBox.values.toList();
  }

  Future<void> permanentlyDeletePhoto(String imageBase64) async {
    final index = _deletedPhotosBox.values.toList().indexWhere(
      (photo) => photo.imageBase64 == imageBase64,
    );
    if (index != -1) {
      await _deletedPhotosBox.deleteAt(index);
    }
  }

  Future<bool> hasUpdates() async {
    return false;
  }
}
