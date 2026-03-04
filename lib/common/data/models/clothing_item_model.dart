// clothing_item_model.dart
import 'package:endimata/common/domain/entities/clothing_item_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clothing_item_model.g.dart';

@JsonSerializable()
class ClothingItemModel extends ClothingItemEntity {
  const ClothingItemModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.category,
    required super.subcategory,
    required super.subSubcategory,
  });

  factory ClothingItemModel.fromJson(Map<String, dynamic> json) =>
      _$ClothingItemModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ClothingItemModelToJson(this);

  static ClothingItemEntity toEntity(ClothingItemModel model) {
    return ClothingItemEntity(
      id: model.id,
      name: model.name,
      imageUrl: model.imageUrl,
      category: model.category,
      subcategory: model.subcategory,
      subSubcategory: model.subSubcategory,
    );
  }

  static ClothingItemModel fromEntity(ClothingItemEntity entity) {
    return ClothingItemModel(
      id: entity.id,
      name: entity.name,
      imageUrl: entity.imageUrl,
      category: entity.category,
      subcategory: entity.subcategory,
      subSubcategory: entity.subSubcategory,
    );
  }
}
