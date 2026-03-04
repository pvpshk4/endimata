// filter_wardrobe_by_category.dart
import 'package:endimata/common/domain/entities/clothing_item_entity.dart';

import '../repositories/wardrobe_repository.dart';

class FilterWardrobeByCategoryUseCase {
  final WardrobeRepository _wardrobeRepository;

  FilterWardrobeByCategoryUseCase(this._wardrobeRepository);

  Future<List<ClothingItemEntity>> call({
    required String category,
    required String subcategory,
    required String filter,
  }) async {
    final items = await _wardrobeRepository.filterWardrobeByCategory(
      category: category,
      subcategory: subcategory,
    );
    return items.where((item) => item.name.contains(filter)).toList();
  }
}
