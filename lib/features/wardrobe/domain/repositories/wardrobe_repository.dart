import 'package:endimata/common/domain/entities/clothing_item_entity.dart';

abstract class WardrobeRepository {
  Future<List<ClothingItemEntity>> getWardrobeItems({
    required String username,
    required String category,
    required String subcategory,
    required String subSubcategory,
    required int page,
    required int limit,
  });

  Future<List<ClothingItemEntity>> refreshWardrobeItems({
    required String username,
    required String category,
    required String subcategory,
    required String subSubcategory,
    required int page,
    required int limit,
  });

  Future<List<ClothingItemEntity>> filterWardrobeByCategory({
    required String category,
    required String subcategory,
  });

  Future<void> deleteClothingItem(String id);

  Future<void> addWardrobeItem(ClothingItemEntity item);
}
