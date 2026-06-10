// clothing_item_entity.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clothing_item_entity.g.dart';

@JsonSerializable()
class ClothingItemEntity extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String category;
  final String subcategory;
  final String subSubcategory;

  const ClothingItemEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.subcategory,
    required this.subSubcategory,
  });

  factory ClothingItemEntity.fromJson(Map<String, dynamic> json) =>
      _$ClothingItemEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ClothingItemEntityToJson(this);

  @override
  List<Object?> get props => [
    id,
    name,
    imageUrl,
    category,
    subcategory,
    subSubcategory,
  ];
}
