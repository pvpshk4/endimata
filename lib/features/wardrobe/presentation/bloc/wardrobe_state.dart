import 'package:equatable/equatable.dart';
import 'package:endimata/common/domain/entities/clothing_item_entity.dart';

abstract class WardrobeState extends Equatable {
  final List<String> categories;
  final List<String> subcategories;
  final List<String> subSubcategories;

  const WardrobeState({
    this.categories = const [],
    this.subcategories = const [],
    this.subSubcategories = const [],
  });

  @override
  List<Object?> get props => [categories, subcategories, subSubcategories];
}

class WardrobeInitialState extends WardrobeState {
  const WardrobeInitialState();
}

class WardrobeLoadingState extends WardrobeState {
  const WardrobeLoadingState({
    super.categories,
    super.subcategories,
    super.subSubcategories,
  });
}

class WardrobeLoadingMoreState extends WardrobeState {
  final Map<String, List<ClothingItemEntity>> groupedItems;

  const WardrobeLoadingMoreState(
    this.groupedItems, {
    super.categories,
    super.subcategories,
    super.subSubcategories,
  });

  @override
  List<Object?> get props => [
    groupedItems,
    categories,
    subcategories,
    subSubcategories,
  ];
}

class WardrobeLoadedState extends WardrobeState {
  final Map<String, List<ClothingItemEntity>> groupedItems;
  final bool hasMoreItems;

  const WardrobeLoadedState(
    this.groupedItems, {
    required this.hasMoreItems,
    super.categories,
    super.subcategories,
    super.subSubcategories,
  });

  @override
  List<Object?> get props => [
    groupedItems,
    hasMoreItems,
    categories,
    subcategories,
    subSubcategories,
  ];
}

class WardrobeFilteredState extends WardrobeState {
  final Map<String, List<ClothingItemEntity>> filteredItems;

  const WardrobeFilteredState(
    this.filteredItems, {
    super.categories,
    super.subcategories,
    super.subSubcategories,
  });

  @override
  List<Object?> get props => [
    filteredItems,
    categories,
    subcategories,
    subSubcategories,
  ];
}

class WardrobeErrorState extends WardrobeState {
  final String message;

  const WardrobeErrorState(
    this.message, {
    super.categories,
    super.subcategories,
    super.subSubcategories,
  });

  @override
  List<Object?> get props => [
    message,
    categories,
    subcategories,
    subSubcategories,
  ];
}

class CategoriesLoadedState extends WardrobeState {
  const CategoriesLoadedState({
    super.categories,
    super.subcategories,
    super.subSubcategories,
  });
}

class SubcategoriesLoadedState extends WardrobeState {
  const SubcategoriesLoadedState({
    super.categories,
    super.subcategories,
    super.subSubcategories,
  });
}

class SubSubcategoriesLoadedState extends WardrobeState {
  const SubSubcategoriesLoadedState({
    super.categories,
    super.subcategories,
    super.subSubcategories,
  });
}

class SearchResultState extends WardrobeState {
  final String category;
  final String subcategory;
  final String subSubcategory;

  const SearchResultState({
    required this.category,
    required this.subcategory,
    required this.subSubcategory,
    super.categories,
    super.subcategories,
    super.subSubcategories,
  });

  @override
  List<Object?> get props => [category, subcategory, subSubcategory];
}

class AllSubSubcategoriesLoadedState extends WardrobeState {
  final List<Map<String, String>> allSubSubcategories;

  const AllSubSubcategoriesLoadedState({
    required this.allSubSubcategories,
    super.categories,
    super.subcategories,
    super.subSubcategories,
  });

  @override
  List<Object?> get props => [
    categories,
    subcategories,
    subSubcategories,
    allSubSubcategories,
  ];
}
