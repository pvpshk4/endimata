import 'dart:convert';

import 'package:endimata/features/home/domain/entities/home_content_entity.dart';

class HomeContentModel extends HomeContentEntity {
  const HomeContentModel({required super.title, required super.description});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'title': title, 'description': description};
  }

  factory HomeContentModel.fromMap(Map<String, dynamic> map) {
    return HomeContentModel(
      title: map['title'] as String,
      description: map['description'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory HomeContentModel.fromJson(String source) =>
      HomeContentModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}
