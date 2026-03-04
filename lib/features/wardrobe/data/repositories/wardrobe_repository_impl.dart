import 'package:endimata/common/data/models/clothing_item_model.dart';
import 'package:endimata/common/domain/entities/clothing_item_entity.dart';
import 'package:endimata/features/wardrobe/data/data_sources/remote/wardrobe_remote_data_source.dart';
import 'package:endimata/features/wardrobe/domain/repositories/wardrobe_repository.dart';

class WardrobeRepositoryImpl implements WardrobeRepository {
  final WardrobeRemoteDataSource _remoteDataSource;

  WardrobeRepositoryImpl({required WardrobeRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<List<ClothingItemEntity>> getWardrobeItems({
    required String username,
    required String category,
    required String subcategory,
    required String subSubcategory,
    required int page,
    required int limit,
  }) async {
    final remoteModels = await _remoteDataSource.getWardrobeItems(
      username: username,
      category: category,
      subcategory: subcategory,
      subSubcategory: subSubcategory,
      page: page,
      limit: limit,
    );
    return remoteModels
        .map((model) => ClothingItemModel.toEntity(model))
        .toList();
  }

  @override
  Future<List<ClothingItemEntity>> refreshWardrobeItems({
    required String username,
    required String category,
    required String subcategory,
    required String subSubcategory,
    required int page,
    required int limit,
  }) async {
    final remoteModels = await _remoteDataSource.getWardrobeItems(
      username: username,
      category: category,
      subcategory: subcategory,
      subSubcategory: subSubcategory,
      page: page,
      limit: limit,
    );
    return remoteModels
        .map((model) => ClothingItemModel.toEntity(model))
        .toList();
  }

  @override
  Future<List<ClothingItemEntity>> filterWardrobeByCategory({
    required String category,
    required String subcategory,
    String filter = '',
  }) async {
    final remoteModels = await _remoteDataSource.filterWardrobeByCategory(
      category: category,
      subcategory: subcategory,
      filter: filter,
    );
    return remoteModels
        .map((model) => ClothingItemModel.toEntity(model))
        .toList();
  }

  @override
  Future<void> deleteClothingItem(String id) async {
    await _remoteDataSource.deleteClothingItem(id);
  }

  @override
  Future<void> addWardrobeItem(ClothingItemEntity item) async {
    final model = ClothingItemModel.fromEntity(item);
    await _remoteDataSource.addWardrobeItem(model);
  }
}
