import 'package:endimata/common/domain/entities/clothing_item_entity.dart';
import '../repositories/wardrobe_repository.dart';

class AddWardrobeItemUseCase {
  final WardrobeRepository _wardrobeRepository;

  AddWardrobeItemUseCase(this._wardrobeRepository);

  Future<void> call(ClothingItemEntity item) async {
    await _wardrobeRepository.addWardrobeItem(item);
  }
}
