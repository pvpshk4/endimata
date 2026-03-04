import 'package:uuid/uuid.dart';
import 'package:endimata/common/data/models/clothing_item_model.dart';
import 'package:endimata/common/AppData/data/models/photo_model.dart';

import '../../../../../common/AppData/data/data_sources/remote/app_data_api_service.dart';

abstract class WardrobeRemoteDataSource {
  Future<List<ClothingItemModel>> getWardrobeItems({
    required String username,
    required String category,
    required String subcategory,
    required String subSubcategory,
    required int page,
    required int limit,
  });

  Future<List<ClothingItemModel>> filterWardrobeByCategory({
    required String category,
    required String subcategory,
    required String filter,
  });

  Future<void> deleteClothingItem(String id);

  Future<void> addWardrobeItem(ClothingItemModel item);
}

class WardrobeRemoteDataSourceImpl implements WardrobeRemoteDataSource {
  final AppDataApiService _apiService;

  WardrobeRemoteDataSourceImpl(this._apiService);

  ClothingItemModel _convertPhotoModelToClothingItemModel(PhotoModel photo) {
    return ClothingItemModel(
      id: const Uuid().v4(),
      name: 'Item_${photo.category}_${photo.subcategory}',
      imageUrl: 'data:image/png;base64,${photo.image}',
      category: photo.category,
      subcategory: photo.subcategory,
      subSubcategory: photo.sub_subcategory,
    );
  }

  PhotoModel _convertClothingItemModelToPhotoModel(ClothingItemModel item) {
    return PhotoModel(
      user_name: 'test_user',
      image: item.imageUrl.split(',').last,
      category: item.category,
      subcategory: item.subcategory,
      sub_subcategory: item.subSubcategory,
    );
  }

  @override
  Future<List<ClothingItemModel>> getWardrobeItems({
    required String username,
    required String category,
    required String subcategory,
    required String subSubcategory,
    required int page,
    required int limit,
  }) async {
    final allItems = await _apiService.getWardrobeItems();
    final filteredItems =
        allItems
            .where(
              (item) =>
                  item.category == category &&
                  item.subcategory == subcategory &&
                  item.sub_subcategory == subSubcategory,
            )
            .skip((page - 1) * limit)
            .take(limit)
            .map(_convertPhotoModelToClothingItemModel)
            .toList();
    return filteredItems;
  }

  @override
  Future<List<ClothingItemModel>> filterWardrobeByCategory({
    required String category,
    required String subcategory,
    required String filter,
  }) async {
    final allItems = await _apiService.getWardrobeItems();
    final filteredItems =
        allItems
            .where(
              (item) =>
                  item.category == category &&
                  item.subcategory == subcategory &&
                  (filter.isEmpty ||
                      item.sub_subcategory.toLowerCase().contains(
                        filter.toLowerCase(),
                      )),
            )
            .map(_convertPhotoModelToClothingItemModel)
            .toList();
    return filteredItems;
  }

  @override
  Future<void> deleteClothingItem(String id) async {
    throw UnimplementedError(
      'Delete operation not supported in AppDataApiService',
    );
  }

  @override
  Future<void> addWardrobeItem(ClothingItemModel item) async {
    final photoModel = _convertClothingItemModelToPhotoModel(item);
    await _apiService.addClothingItem(
      photoModel.image,
      photoModel.user_name,
      photoModel.category,
      photoModel.subcategory,
      photoModel.sub_subcategory,
    );
  }
}
