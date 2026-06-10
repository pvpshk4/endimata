import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String category;
  const CategoryEntity({required this.id, required this.category});

  CategoryEntity copyWith({String? id, String? name}) {
    return CategoryEntity(id: id ?? this.id, category: name ?? category);
  }

  @override
  List<Object> get props => [id, category];
}
