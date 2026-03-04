import 'package:endimata/common/domain/entities/clothing_item_entity.dart';

import '../repositories/wardrobe_repository.dart';

class GetWardrobeItemsUseCase {
  final WardrobeRepository _wardrobeRepository;

  GetWardrobeItemsUseCase(this._wardrobeRepository);

  Future<List<ClothingItemEntity>> call({
    required String username,
    required String category,
    required String subcategory,
    required String subSubcategory,
    required int page,
    required int limit,
  }) async {
    return await _wardrobeRepository.getWardrobeItems(
      username: username,
      category: category,
      subcategory: subcategory,
      subSubcategory: subSubcategory,
      page: page,
      limit: limit,
    );
  }
}
