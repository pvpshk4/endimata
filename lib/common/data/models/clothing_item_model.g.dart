// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clothing_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClothingItemModel _$ClothingItemModelFromJson(Map<String, dynamic> json) =>
    ClothingItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String,
      subSubcategory: json['subSubcategory'] as String,
    );

Map<String, dynamic> _$ClothingItemModelToJson(ClothingItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'category': instance.category,
      'subcategory': instance.subcategory,
      'subSubcategory': instance.subSubcategory,
    };
