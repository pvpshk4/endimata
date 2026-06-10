import 'package:hive/hive.dart';
import 'photo_model.dart';

class PhotoModelAdapter extends TypeAdapter<PhotoModel> {
  @override
  final int typeId = 1;

  @override
  PhotoModel read(BinaryReader reader) {
    final map = reader.readMap().cast<String, dynamic>();
    return PhotoModel(
      user_name: map['user_name'] as String? ?? '',
      image: map['image'] as String? ?? '',
      category: map['category'] as String? ?? '',
      subcategory: map['subcategory'] as String? ?? '',
      sub_subcategory: map['sub_subcategory'] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, PhotoModel obj) {
    writer.writeMap({
      'user_name': obj.user_name,
      'image': obj.image,
      'category': obj.category,
      'subcategory': obj.subcategory,
      'sub_subcategory': obj.sub_subcategory,
    });
  }
}
