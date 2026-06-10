import 'package:equatable/equatable.dart';
import 'package:endimata/common/AppData/data/models/photo_model.dart';

enum TryOnStatus { idle, loading, done, error }

abstract class HomeState extends Equatable {
  final List<PhotoModel> catalogItems;
  final List<PhotoModel> wardrobeItems;
  final String catalogCategory;
  final String catalogSubcategory;
  final String catalogSubSubcategory;
  final String wardrobeCategory;
  final String wardrobeSubcategory;
  final String wardrobeSubSubcategory;

  // Состояние примерки
  final TryOnStatus tryOnStatus;
  final String? tryOnTaskId;
  final String? tryOnResultBase64;
  final String? tryOnError;

  const HomeState({
    this.catalogItems = const [],
    this.wardrobeItems = const [],
    this.catalogCategory = '',
    this.catalogSubcategory = '',
    this.catalogSubSubcategory = '',
    this.wardrobeCategory = '',
    this.wardrobeSubcategory = '',
    this.wardrobeSubSubcategory = '',
    this.tryOnStatus = TryOnStatus.idle,
    this.tryOnTaskId,
    this.tryOnResultBase64,
    this.tryOnError,
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
    tryOnStatus,
    tryOnTaskId,
    tryOnResultBase64,
    tryOnError,
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
    super.tryOnStatus,
    super.tryOnTaskId,
    super.tryOnResultBase64,
    super.tryOnError,
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
    super.tryOnStatus,
    super.tryOnTaskId,
    super.tryOnResultBase64,
    super.tryOnError,
  });

  HomeLoadedState copyWithTryOn({
    TryOnStatus? tryOnStatus,
    String? tryOnTaskId,
    String? tryOnResultBase64,
    String? tryOnError,
  }) {
    return HomeLoadedState(
      catalogItems: catalogItems,
      wardrobeItems: wardrobeItems,
      catalogCategory: catalogCategory,
      catalogSubcategory: catalogSubcategory,
      catalogSubSubcategory: catalogSubSubcategory,
      wardrobeCategory: wardrobeCategory,
      wardrobeSubcategory: wardrobeSubcategory,
      wardrobeSubSubcategory: wardrobeSubSubcategory,
      tryOnStatus: tryOnStatus ?? this.tryOnStatus,
      tryOnTaskId: tryOnTaskId ?? this.tryOnTaskId,
      tryOnResultBase64: tryOnResultBase64 ?? this.tryOnResultBase64,
      tryOnError: tryOnError ?? this.tryOnError,
    );
  }
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
    super.tryOnStatus,
    super.tryOnTaskId,
    super.tryOnResultBase64,
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
    super.tryOnStatus,
    super.tryOnTaskId,
    super.tryOnResultBase64,
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
    super.tryOnStatus,
    super.tryOnTaskId,
    super.tryOnResultBase64,
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
    super.tryOnStatus,
    super.tryOnTaskId,
    super.tryOnResultBase64,
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
    super.tryOnStatus,
    super.tryOnTaskId,
    super.tryOnResultBase64,
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
    super.tryOnStatus,
    super.tryOnTaskId,
    super.tryOnResultBase64,
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
    super.tryOnStatus,
    super.tryOnTaskId,
    super.tryOnResultBase64,
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
    super.tryOnStatus,
    super.tryOnTaskId,
    super.tryOnResultBase64,
  });

  @override
  List<Object?> get props => [
    message,
    catalogItems,
    wardrobeItems,
    tryOnStatus,
    tryOnTaskId,
    tryOnResultBase64,
  ];
}
