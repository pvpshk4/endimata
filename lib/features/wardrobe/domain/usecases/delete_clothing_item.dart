import '../repositories/wardrobe_repository.dart';

class DeleteClothingItemUseCase {
  final WardrobeRepository _wardrobeRepository;

  DeleteClothingItemUseCase(this._wardrobeRepository);

  Future<void> call(String id) async {
    await _wardrobeRepository.deleteClothingItem(id);
  }
}
