import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:endimata/common/AppData/data/models/photo_model.dart';

part 'deleted_photo_model.g.dart';

@HiveType(typeId: 2)
// ignore: must_be_immutable
class DeletedPhotoModel extends Equatable with HiveObjectMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type;

  @HiveField(2)
  final String imageBase64;

  @HiveField(3)
  final String userName;

  @HiveField(4)
  final String? category;

  @HiveField(5)
  final String? subcategory;

  @HiveField(6)
  final String? subSubcategory;

  DeletedPhotoModel({
    required this.id,
    required this.type,
    required this.imageBase64,
    required this.userName,
    this.category,
    this.subcategory,
    this.subSubcategory,
  });

  factory DeletedPhotoModel.fromHumanPhoto(
    String imageBase64,
    String userName,
    String id,
  ) {
    return DeletedPhotoModel(
      id: id,
      type: 'human',
      imageBase64: imageBase64,
      userName: userName,
    );
  }

  factory DeletedPhotoModel.fromWardrobeItem(PhotoModel photoModel, String id) {
    return DeletedPhotoModel(
      id: id,
      type: 'wardrobe',
      imageBase64: photoModel.image,
      userName: photoModel.user_name,
      category: photoModel.category,
      subcategory: photoModel.subcategory,
      subSubcategory: photoModel.sub_subcategory,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    imageBase64,
    userName,
    category,
    subcategory,
    subSubcategory,
  ];
}
