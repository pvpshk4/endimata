import 'package:equatable/equatable.dart';

abstract class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => [];
}

class SelectCategoryEvent extends CatalogEvent {
  final String categoryName;

  const SelectCategoryEvent(this.categoryName);

  @override
  List<Object?> get props => [categoryName];
}

class SelectSubcategoryEvent extends CatalogEvent {
  final String subcategoryName;

  const SelectSubcategoryEvent(this.subcategoryName);

  @override
  List<Object?> get props => [subcategoryName];
}

class SelectSubSubcategoryEvent extends CatalogEvent {
  final String subSubcategoryName;

  const SelectSubSubcategoryEvent(this.subSubcategoryName);

  @override
  List<Object?> get props => [subSubcategoryName];
}

class GoBackEvent extends CatalogEvent {
  final int index;

  const GoBackEvent(this.index);

  @override
  List<Object?> get props => [index];
}
