import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:endimata/common/AppData/presentation/bloc/app_data_bloc.dart';
import 'package:endimata/common/AppData/data/models/photo_model.dart';
import '../../../../common/AppData/presentation/bloc/app_data_event.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AppDataBloc appDataBloc;

  HomeBloc(this.appDataBloc) : super(const HomeInitialState()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<SelectCategoryEvent>(_onSelectCategory);
    on<SelectSubcategoryEvent>(_onSelectSubcategory);
    on<SelectSubSubcategoryEvent>(_onSelectSubSubcategory);
    on<ResetFilterEvent>(_onResetFilter);
    on<GoToPreviousEvent>(_onGoToPrevious);

    add(LoadHomeDataEvent());
  }

  List<PhotoModel> _filterItems({
    required List<PhotoModel> items,
    required String category,
    required String subcategory,
    required String subSubcategory,
  }) {
    return items.where((item) {
      final matchesCategory = category.isEmpty || item.category == category;
      final matchesSubcategory =
          subcategory.isEmpty || item.subcategory == subcategory;
      final matchesSubSubcategory =
          subSubcategory.isEmpty || item.sub_subcategory == subSubcategory;
      return matchesCategory && matchesSubcategory && matchesSubSubcategory;
    }).toList();
  }

  Future<void> _onLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoadingState());

    final appDataState = appDataBloc.state;
    if (appDataState.isLoading) {
      emit(const HomeErrorState('Данные еще загружаются'));
      return;
    }

    if (appDataState.error != null) {
      emit(HomeErrorState(appDataState.error!));
      return;
    }

    final filteredCatalogItems = _filterItems(
      items: appDataState.catalogItems,
      category: state.catalogCategory,
      subcategory: state.catalogSubcategory,
      subSubcategory: state.catalogSubSubcategory,
    );

    final filteredWardrobeItems = _filterItems(
      items: appDataState.wardrobeItems,
      category: state.wardrobeCategory,
      subcategory: state.wardrobeSubcategory,
      subSubcategory: state.wardrobeSubSubcategory,
    );

    final selectedPhoto = appDataBloc.state.selectedHumanPhoto;
    if (selectedPhoto != null &&
        !appDataBloc.state.humanPhotos.contains(selectedPhoto)) {
      appDataBloc.add(const SetSelectedPhotoEvent(null));
    }

    emit(
      HomeLoadedState(
        catalogItems: filteredCatalogItems,
        wardrobeItems: filteredWardrobeItems,
        catalogCategory: state.catalogCategory,
        catalogSubcategory: state.catalogSubcategory,
        catalogSubSubcategory: state.catalogSubSubcategory,
        wardrobeCategory: state.wardrobeCategory,
        wardrobeSubcategory: state.wardrobeSubcategory,
        wardrobeSubSubcategory: state.wardrobeSubSubcategory,
      ),
    );
  }

  void _onSelectCategory(SelectCategoryEvent event, Emitter<HomeState> emit) {
    final appDataState = appDataBloc.state;

    if (event.isCatalogTab) {
      final filteredCatalogItems = _filterItems(
        items: appDataState.catalogItems,
        category: event.categoryName,
        subcategory: '',
        subSubcategory: '',
      );

      emit(
        HomeCatalogCategorySelectedState(
          catalogItems: filteredCatalogItems,
          wardrobeItems: state.wardrobeItems,
          catalogCategory: event.categoryName,
          catalogSubcategory: '',
          catalogSubSubcategory: '',
          wardrobeCategory: state.wardrobeCategory,
          wardrobeSubcategory: state.wardrobeSubcategory,
          wardrobeSubSubcategory: state.wardrobeSubSubcategory,
        ),
      );
    } else {
      final filteredWardrobeItems = _filterItems(
        items: appDataState.wardrobeItems,
        category: event.categoryName,
        subcategory: '',
        subSubcategory: '',
      );

      emit(
        HomeWardrobeCategorySelectedState(
          catalogItems: state.catalogItems,
          wardrobeItems: filteredWardrobeItems,
          catalogCategory: state.catalogCategory,
          catalogSubcategory: state.catalogSubcategory,
          catalogSubSubcategory: state.catalogSubSubcategory,
          wardrobeCategory: event.categoryName,
          wardrobeSubcategory: '',
          wardrobeSubSubcategory: '',
        ),
      );
    }
  }

  void _onSelectSubcategory(
    SelectSubcategoryEvent event,
    Emitter<HomeState> emit,
  ) {
    final appDataState = appDataBloc.state;

    if (event.isCatalogTab) {
      final filteredCatalogItems = _filterItems(
        items: appDataState.catalogItems,
        category: state.catalogCategory,
        subcategory: event.subcategoryName,
        subSubcategory: '',
      );

      emit(
        HomeCatalogSubcategorySelectedState(
          catalogItems: filteredCatalogItems,
          wardrobeItems: state.wardrobeItems,
          catalogCategory: state.catalogCategory,
          catalogSubcategory: event.subcategoryName,
          catalogSubSubcategory: '',
          wardrobeCategory: state.wardrobeCategory,
          wardrobeSubcategory: state.wardrobeSubcategory,
          wardrobeSubSubcategory: state.wardrobeSubSubcategory,
        ),
      );
    } else {
      final filteredWardrobeItems = _filterItems(
        items: appDataState.wardrobeItems,
        category: state.wardrobeCategory,
        subcategory: event.subcategoryName,
        subSubcategory: '',
      );

      emit(
        HomeWardrobeSubcategorySelectedState(
          catalogItems: state.catalogItems,
          wardrobeItems: filteredWardrobeItems,
          catalogCategory: state.catalogCategory,
          catalogSubcategory: state.catalogSubcategory,
          catalogSubSubcategory: state.catalogSubSubcategory,
          wardrobeCategory: state.wardrobeCategory,
          wardrobeSubcategory: event.subcategoryName,
          wardrobeSubSubcategory: '',
        ),
      );
    }
  }

  void _onSelectSubSubcategory(
    SelectSubSubcategoryEvent event,
    Emitter<HomeState> emit,
  ) {
    final appDataState = appDataBloc.state;

    if (event.isCatalogTab) {
      final filteredCatalogItems = _filterItems(
        items: appDataState.catalogItems,
        category: state.catalogCategory,
        subcategory: state.catalogSubcategory,
        subSubcategory: event.subSubcategoryName,
      );

      emit(
        HomeCatalogSubSubcategorySelectedState(
          catalogItems: filteredCatalogItems,
          wardrobeItems: state.wardrobeItems,
          catalogCategory: state.catalogCategory,
          catalogSubcategory: state.catalogSubcategory,
          catalogSubSubcategory: event.subSubcategoryName,
          wardrobeCategory: state.wardrobeCategory,
          wardrobeSubcategory: state.wardrobeSubcategory,
          wardrobeSubSubcategory: state.wardrobeSubSubcategory,
        ),
      );
    } else {
      final filteredWardrobeItems = _filterItems(
        items: appDataState.wardrobeItems,
        category: state.wardrobeCategory,
        subcategory: state.wardrobeSubcategory,
        subSubcategory: event.subSubcategoryName,
      );

      emit(
        HomeWardrobeSubSubcategorySelectedState(
          catalogItems: state.catalogItems,
          wardrobeItems: filteredWardrobeItems,
          catalogCategory: state.catalogCategory,
          catalogSubcategory: state.catalogSubcategory,
          catalogSubSubcategory: state.catalogSubSubcategory,
          wardrobeCategory: state.wardrobeCategory,
          wardrobeSubcategory: state.wardrobeSubcategory,
          wardrobeSubSubcategory: event.subSubcategoryName,
        ),
      );
    }
  }

  void _onResetFilter(ResetFilterEvent event, Emitter<HomeState> emit) {
    final appDataState = appDataBloc.state;

    if (event.isCatalogTab) {
      emit(
        HomeResetFilterState(
          catalogItems: appDataState.catalogItems,
          wardrobeItems: state.wardrobeItems,
          catalogCategory: '',
          catalogSubcategory: '',
          catalogSubSubcategory: '',
          wardrobeCategory: state.wardrobeCategory,
          wardrobeSubcategory: state.wardrobeSubcategory,
          wardrobeSubSubcategory: state.wardrobeSubSubcategory,
        ),
      );
    } else {
      emit(
        HomeResetFilterState(
          catalogItems: state.catalogItems,
          wardrobeItems: appDataState.wardrobeItems,
          catalogCategory: state.catalogCategory,
          catalogSubcategory: state.catalogSubcategory,
          catalogSubSubcategory: state.catalogSubSubcategory,
          wardrobeCategory: '',
          wardrobeSubcategory: '',
          wardrobeSubSubcategory: '',
        ),
      );
    }
  }

  void _onGoToPrevious(GoToPreviousEvent event, Emitter<HomeState> emit) {
    final appDataState = appDataBloc.state;

    if (event.isCatalogTab) {
      if (event.level == 0) {
        emit(
          HomeResetFilterState(
            catalogItems: appDataState.catalogItems,
            wardrobeItems: state.wardrobeItems,
            catalogCategory: '',
            catalogSubcategory: '',
            catalogSubSubcategory: '',
            wardrobeCategory: state.wardrobeCategory,
            wardrobeSubcategory: state.wardrobeSubcategory,
            wardrobeSubSubcategory: state.wardrobeSubSubcategory,
          ),
        );
      } else if (event.level == 1) {
        final filteredCatalogItems = _filterItems(
          items: appDataState.catalogItems,
          category: state.catalogCategory,
          subcategory: '',
          subSubcategory: '',
        );
        emit(
          HomeCatalogCategorySelectedState(
            catalogItems: filteredCatalogItems,
            wardrobeItems: state.wardrobeItems,
            catalogCategory: state.catalogCategory,
            catalogSubcategory: '',
            catalogSubSubcategory: '',
            wardrobeCategory: state.wardrobeCategory,
            wardrobeSubcategory: state.wardrobeSubcategory,
            wardrobeSubSubcategory: state.wardrobeSubSubcategory,
          ),
        );
      } else if (event.level == 2) {
        final filteredCatalogItems = _filterItems(
          items: appDataState.catalogItems,
          category: state.catalogCategory,
          subcategory: state.catalogSubcategory,
          subSubcategory: '',
        );
        emit(
          HomeCatalogSubcategorySelectedState(
            catalogItems: filteredCatalogItems,
            wardrobeItems: state.wardrobeItems,
            catalogCategory: state.catalogCategory,
            catalogSubcategory: state.catalogSubcategory,
            catalogSubSubcategory: '',
            wardrobeCategory: state.wardrobeCategory,
            wardrobeSubcategory: state.wardrobeSubcategory,
            wardrobeSubSubcategory: state.wardrobeSubSubcategory,
          ),
        );
      }
    } else {
      if (event.level == 0) {
        emit(
          HomeResetFilterState(
            catalogItems: state.catalogItems,
            wardrobeItems: appDataState.wardrobeItems,
            catalogCategory: state.catalogCategory,
            catalogSubcategory: state.catalogSubcategory,
            catalogSubSubcategory: state.catalogSubSubcategory,
            wardrobeCategory: '',
            wardrobeSubcategory: '',
            wardrobeSubSubcategory: '',
          ),
        );
      } else if (event.level == 1) {
        final filteredWardrobeItems = _filterItems(
          items: appDataState.wardrobeItems,
          category: state.wardrobeCategory,
          subcategory: '',
          subSubcategory: '',
        );
        emit(
          HomeWardrobeCategorySelectedState(
            catalogItems: state.catalogItems,
            wardrobeItems: filteredWardrobeItems,
            catalogCategory: state.catalogCategory,
            catalogSubcategory: state.catalogSubcategory,
            catalogSubSubcategory: state.catalogSubSubcategory,
            wardrobeCategory: state.wardrobeCategory,
            wardrobeSubcategory: '',
            wardrobeSubSubcategory: '',
          ),
        );
      } else if (event.level == 2) {
        final filteredWardrobeItems = _filterItems(
          items: appDataState.wardrobeItems,
          category: state.wardrobeCategory,
          subcategory: state.wardrobeSubcategory,
          subSubcategory: '',
        );
        emit(
          HomeWardrobeSubcategorySelectedState(
            catalogItems: state.catalogItems,
            wardrobeItems: filteredWardrobeItems,
            catalogCategory: state.catalogCategory,
            catalogSubcategory: state.catalogSubcategory,
            catalogSubSubcategory: state.catalogSubSubcategory,
            wardrobeCategory: state.wardrobeCategory,
            wardrobeSubcategory: state.wardrobeSubcategory,
            wardrobeSubSubcategory: '',
          ),
        );
      }
    }
  }
}
