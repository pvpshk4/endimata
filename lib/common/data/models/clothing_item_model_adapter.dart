import 'package:hive/hive.dart';
import 'package:endimata/common/data/models/clothing_item_model.dart';

class ClothingItemModelAdapter extends TypeAdapter<ClothingItemModel> {
  @override
  final int typeId = 0;

  @override
  ClothingItemModel read(BinaryReader reader) {
    final map = reader.readMap().cast<String, dynamic>();
    return ClothingItemModel(
      id: map['id'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      category: map['category'],
      subcategory: map['subcategory'],
      subSubcategory: map['subSubcategory'],
    );
  }

  @override
  void write(BinaryWriter writer, ClothingItemModel obj) {
    writer.writeMap({
      'id': obj.id,
      'name': obj.name,
      'imageUrl': obj.imageUrl,
      'category': obj.category,
      'subcategory': obj.subcategory,
      'subSubcategory': obj.subSubcategory,
    });
  }
}
