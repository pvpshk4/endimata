import 'package:equatable/equatable.dart';

class PhotoEntity extends Equatable {
  final String user_name;
  final String image;
  final String category;
  final String subcategory;
  final String sub_subcategory;

  const PhotoEntity({
    required this.user_name,
    required this.image,
    required this.category,
    required this.subcategory,
    required this.sub_subcategory,
  });

  PhotoEntity copyWith({
    String? user_name,
    String? image,
    String? category,
    String? subcategory,
    String? sub_subcategory,
    bool? isWardrobe,
  }) {
    return PhotoEntity(
      user_name: user_name ?? this.user_name,
      image: image ?? this.image,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      sub_subcategory: sub_subcategory ?? this.sub_subcategory,
    );
  }

  @override
  List<Object> get props => [
    user_name,
    image,
    category,
    subcategory,
    sub_subcategory,
  ];
}
