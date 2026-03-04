import 'dart:convert';
import 'package:endimata/common/photo_upload/domain/entities/photo_entity.dart';

class PhotoModel extends PhotoEntity {
  final String? storageUrl;

  const PhotoModel({
    required super.user_name,
    required super.image,
    required super.category,
    required super.subcategory,
    required super.sub_subcategory,
    this.storageUrl,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user_name': user_name,
      'image': image,
      'category': category,
      'subcategory': subcategory,
      'sub_subcategory': sub_subcategory,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoModel &&
          user_name == other.user_name &&
          image == other.image &&
          category == other.category &&
          subcategory == other.subcategory &&
          sub_subcategory == other.sub_subcategory;

  @override
  int get hashCode =>
      user_name.hashCode ^
      image.hashCode ^
      category.hashCode ^
      subcategory.hashCode ^
      sub_subcategory.hashCode;

  factory PhotoModel.fromMap(Map<String, dynamic> map) {
    return PhotoModel(
      user_name: map['user_name'] ?? '',
      image: map['image_base64'] ?? '', // Сервер возвращает image_base64
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? '',
      sub_subcategory: map['sub_subcategory'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      user_name: json['user_name'] ?? '',
      image: json['image_base64'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      sub_subcategory: json['sub_subcategory'] ?? '',
    );
  }
}
