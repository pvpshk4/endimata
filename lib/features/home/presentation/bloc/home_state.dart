import 'package:equatable/equatable.dart';
import 'package:endimata/common/AppData/data/models/photo_model.dart';

abstract class HomeState extends Equatable {
  final List<PhotoModel> catalogItems;
  final List<PhotoModel> wardrobeItems;
  final String catalogCategory;
  final String catalogSubcategory;
  final String catalogSubSubcategory;
  final String wardrobeCategory;
  final String wardrobeSubcategory;
  final String wardrobeSubSubcategory;

  const HomeState({
    this.catalogItems = const [],
    this.wardrobeItems = const [],
    this.catalogCategory = '',
    this.catalogSubcategory = '',
    this.catalogSubSubcategory = '',
    this.wardrobeCategory = '',
    this.wardrobeSubcategory = '',
    this.wardrobeSubSubcategory = '',
  });

  @override
  List<Object?> get props => [
    catalogItems,
    wardrobeItems,
    catalogCategory,
    catalogSubcategory,
    catalogSubSubcategory,
    wardrobeCategory,
    wardrobeSubcategory,
    wardrobeSubSubcategory,
  ];
}

class HomeInitialState extends HomeState {
  const HomeInitialState();
}

class HomeLoadingState extends HomeState {
  const HomeLoadingState({
    super.catalogItems,
    super.wardrobeItems,
    super.catalogCategory,
    super.catalogSubcategory,
    super.catalogSubSubcategory,
    super.wardrobeCategory,
    super.wardrobeSubcategory,
    super.wardrobeSubSubcategory,
  });
}

class HomeLoadedState extends HomeState {
  const HomeLoadedState({
    required super.catalogItems,
    required super.wardrobeItems,
    super.catalogCategory,
    super.catalogSubcategory,
    super.catalogSubSubcategory,
    super.wardrobeCategory,
    super.wardrobeSubcategory,
    super.wardrobeSubSubcategory,
  });
}

class HomeCatalogCategorySelectedState extends HomeState {
  const HomeCatalogCategorySelectedState({
    required super.catalogItems,
    required super.wardrobeItems,
    super.catalogCategory,
    super.catalogSubcategory,
    super.catalogSubSubcategory,
    super.wardrobeCategory,
    super.wardrobeSubcategory,
    super.wardrobeSubSubcategory,
  });
}

class HomeCatalogSubcategorySelectedState extends HomeState {
  const HomeCatalogSubcategorySelectedState({
    required super.catalogItems,
    required super.wardrobeItems,
    super.catalogCategory,
    super.catalogSubcategory,
    super.catalogSubSubcategory,
    super.wardrobeCategory,
    super.wardrobeSubcategory,
    super.wardrobeSubSubcategory,
  });
}

class HomeCatalogSubSubcategorySelectedState extends HomeState {
  const HomeCatalogSubSubcategorySelectedState({
    required super.catalogItems,
    required super.wardrobeItems,
    super.catalogCategory,
    super.catalogSubcategory,
    super.catalogSubSubcategory,
    super.wardrobeCategory,
    super.wardrobeSubcategory,
    super.wardrobeSubSubcategory,
  });
}

class HomeWardrobeCategorySelectedState extends HomeState {
  const HomeWardrobeCategorySelectedState({
    required super.catalogItems,
    required super.wardrobeItems,
    super.catalogCategory,
    super.catalogSubcategory,
    super.catalogSubSubcategory,
    super.wardrobeCategory,
    super.wardrobeSubcategory,
    super.wardrobeSubSubcategory,
  });
}

class HomeWardrobeSubcategorySelectedState extends HomeState {
  const HomeWardrobeSubcategorySelectedState({
    required super.catalogItems,
    required super.wardrobeItems,
    super.catalogCategory,
    super.catalogSubcategory,
    super.catalogSubSubcategory,
    super.wardrobeCategory,
    super.wardrobeSubcategory,
    super.wardrobeSubSubcategory,
  });
}

class HomeWardrobeSubSubcategorySelectedState extends HomeState {
  const HomeWardrobeSubSubcategorySelectedState({
    required super.catalogItems,
    required super.wardrobeItems,
    super.catalogCategory,
    super.catalogSubcategory,
    super.catalogSubSubcategory,
    super.wardrobeCategory,
    super.wardrobeSubcategory,
    super.wardrobeSubSubcategory,
  });
}

class HomeResetFilterState extends HomeState {
  const HomeResetFilterState({
    required super.catalogItems,
    required super.wardrobeItems,
    super.catalogCategory,
    super.catalogSubcategory,
    super.catalogSubSubcategory,
    super.wardrobeCategory,
    super.wardrobeSubcategory,
    super.wardrobeSubSubcategory,
  });
}

class HomeErrorState extends HomeState {
  final String message;

  const HomeErrorState(
    this.message, {
    super.catalogItems,
    super.wardrobeItems,
    super.catalogCategory,
    super.catalogSubcategory,
    super.catalogSubSubcategory,
    super.wardrobeCategory,
    super.wardrobeSubcategory,
    super.wardrobeSubSubcategory,
  });

  @override
  List<Object?> get props => [
    message,
    catalogItems,
    wardrobeItems,
    catalogCategory,
    catalogSubcategory,
    catalogSubSubcategory,
    wardrobeCategory,
    wardrobeSubcategory,
    wardrobeSubSubcategory,
  ];
}
