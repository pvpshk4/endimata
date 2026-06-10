import 'package:flutter_bloc/flutter_bloc.dart';

import 'catalog_event.dart';
import 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc() : super(const CatalogState()) {
    on<SelectCategoryEvent>(_onSelectCategory);
    on<SelectSubcategoryEvent>(_onSelectSubcategory);
    on<SelectSubSubcategoryEvent>(_onSelectSubSubcategory);
    on<GoBackEvent>(_onGoBack);
  }

  void _onSelectCategory(
    SelectCategoryEvent event,
    Emitter<CatalogState> emit,
  ) {
    emit(
      state.copyWith(
        navigationPath: [event.categoryName],
        selectedCategory: event.categoryName,
        selectedSubcategory: null,
        selectedSubSubcategory: null,
      ),
    );
  }

  void _onSelectSubcategory(
    SelectSubcategoryEvent event,
    Emitter<CatalogState> emit,
  ) {
    emit(
      state.copyWith(
        navigationPath: [...state.navigationPath, event.subcategoryName],
        selectedSubcategory: event.subcategoryName,
        selectedSubSubcategory: null,
      ),
    );
  }

  void _onSelectSubSubcategory(
    SelectSubSubcategoryEvent event,
    Emitter<CatalogState> emit,
  ) {
    emit(
      state.copyWith(
        navigationPath: [...state.navigationPath, event.subSubcategoryName],
        selectedSubSubcategory: event.subSubcategoryName,
      ),
    );
  }

  void _onGoBack(GoBackEvent event, Emitter<CatalogState> emit) {
    if (event.index == -1) {
      // Очистка пути навигации для возврата к списку категорий
      emit(
        state.copyWith(
          navigationPath: [],
          selectedCategory: null,
          selectedSubcategory: null,
          selectedSubSubcategory: null,
        ),
      );
    } else if (event.index == 0) {
      emit(
        state.copyWith(
          navigationPath: state.navigationPath.sublist(0, 1),
          selectedSubcategory: null,
          selectedSubSubcategory: null,
        ),
      );
    } else if (event.index == 1) {
      emit(
        state.copyWith(
          navigationPath: state.navigationPath.sublist(0, 2),
          selectedSubSubcategory: null,
        ),
      );
    } else {
      emit(
        state.copyWith(
          navigationPath: state.navigationPath.sublist(0, event.index + 1),
        ),
      );
    }
  }
}
