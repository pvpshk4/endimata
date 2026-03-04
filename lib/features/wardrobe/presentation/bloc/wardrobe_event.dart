import 'package:equatable/equatable.dart';
import 'package:endimata/common/domain/entities/clothing_item_entity.dart';

abstract class WardrobeEvent extends Equatable {
  const WardrobeEvent();

  @override
  List<Object> get props => [];
}

class LoadWardrobeEvent extends WardrobeEvent {
  final String username;
  final String category;
  final String subcategory;
  final String subSubcategory;

  const LoadWardrobeEvent({
    required this.username,
    required this.category,
    required this.subcategory,
    required this.subSubcategory,
  });

  @override
  List<Object> get props => [username, category, subcategory];
}

class LoadMoreWardrobeItemsEvent extends WardrobeEvent {
  final String username;
  final String category;
  final String subcategory;
  final String subSubcategory;
  final int page;
  final int limit;

  const LoadMoreWardrobeItemsEvent({
    required this.username,
    required this.category,
    required this.subcategory,
    required this.subSubcategory,
    required this.page,
    required this.limit,
  });

  @override
  List<Object> get props => [
    username,
    category,
    subcategory,
    subSubcategory,
    page,
    limit,
  ];
}

class FilterWardrobeByCategoryEvent extends WardrobeEvent {
  final String category;
  final String subcategory;
  final String filter;

  const FilterWardrobeByCategoryEvent({
    required this.category,
    required this.subcategory,
    required this.filter,
  });

  @override
  List<Object> get props => [category, subcategory, filter];
}

class DeleteClothingItemEvent extends WardrobeEvent {
  final String id;

  const DeleteClothingItemEvent(this.id);

  @override
  List<Object> get props => [id];
}

class UpdateClothingItemEvent extends WardrobeEvent {
  final ClothingItemEntity item;

  const UpdateClothingItemEvent(this.item);

  @override
  List<Object> get props => [item];
}

class LoadCategoriesEvent extends WardrobeEvent {}

class LoadSubcategoriesEvent extends WardrobeEvent {
  final String category;

  const LoadSubcategoriesEvent(this.category);

  @override
  List<Object> get props => [category];
}

class LoadSubSubcategoriesEvent extends WardrobeEvent {
  final String category;
  final String subcategory;

  const LoadSubSubcategoriesEvent(this.category, this.subcategory);

  @override
  List<Object> get props => [category, subcategory];
}

class SearchSubSubcategoryEvent extends WardrobeEvent {
  final String query;

  const SearchSubSubcategoryEvent(this.query);

  @override
  List<Object> get props => [query];
}

class LoadAllSubSubcategoriesEvent extends WardrobeEvent {}

class AddWardrobeItemEvent extends WardrobeEvent {
  final ClothingItemEntity item;

  const AddWardrobeItemEvent(this.item);

  @override
  List<Object> get props => [item];
}
