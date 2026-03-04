import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:endimata/common/data/models/clothing_item_model.dart';
import '../../../../config/app_constants.dart';
import '../../data/data_sources/remote/wardrobe_remote_data_source.dart';
import 'wardrobe_event.dart';
import 'wardrobe_state.dart';

class WardrobeBloc extends Bloc<WardrobeEvent, WardrobeState> {
  final WardrobeRemoteDataSource _remoteDataSource;

  Map<String, List<ClothingItemModel>> _allGroupedItems = {};
  int _currentPage = 1;
  final int _limit = 20;
  bool _hasMoreItems = true;
  List<String> _subSubcategories = [];
  List<String> _categoriesList = [];
  List<String> _subcategories = [];

  WardrobeBloc({required WardrobeRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource,
      super(const WardrobeInitialState()) {
    on<LoadWardrobeEvent>(_onLoadWardrobe);
    on<LoadMoreWardrobeItemsEvent>(_onLoadMoreWardrobe);
    on<FilterWardrobeByCategoryEvent>(_onFilterWardrobe);
    on<DeleteClothingItemEvent>(_onDeleteClothingItem);
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<LoadSubcategoriesEvent>(_onLoadSubcategories);
    on<LoadSubSubcategoriesEvent>(_onLoadSubSubcategories);
    on<SearchSubSubcategoryEvent>(_onSearchSubSubcategory);
    on<LoadAllSubSubcategoriesEvent>(_onLoadAllSubSubcategories);
    on<AddWardrobeItemEvent>(_onAddWardrobeItem);
  }

  Future<void> _onLoadWardrobe(
    LoadWardrobeEvent event,
    Emitter<WardrobeState> emit,
  ) async {
    emit(
      WardrobeLoadingState(
        subSubcategories: _subSubcategories,
        categories: _categoriesList,
        subcategories: _subcategories,
      ),
    );
    try {
      _currentPage = 1;
      _allGroupedItems = {};

      final subSubcategories =
          categories[event.category]?[event.subcategory] ?? [];

      for (final subSubcategory in subSubcategories) {
        final items = await _remoteDataSource.getWardrobeItems(
          username: event.username,
          category: event.category,
          subcategory: event.subcategory,
          subSubcategory: subSubcategory,
          page: _currentPage,
          limit: _limit,
        );
        _allGroupedItems[subSubcategory] = items;
      }

      _hasMoreItems = _allGroupedItems.values.any(
        (items) => items.length == _limit,
      );
      emit(
        WardrobeLoadedState(
          _allGroupedItems.map(
            (key, items) =>
                MapEntry(key, items.map(ClothingItemModel.toEntity).toList()),
          ),
          hasMoreItems: _hasMoreItems,
          subSubcategories: _subSubcategories,
          categories: _categoriesList,
          subcategories: _subcategories,
        ),
      );
    } catch (e) {
      emit(
        WardrobeErrorState(
          'Не удалось загрузить гардероб: $e',
          subSubcategories: _subSubcategories,
          categories: _categoriesList,
          subcategories: _subcategories,
        ),
      );
    }
  }

  Future<void> _onLoadMoreWardrobe(
    LoadMoreWardrobeItemsEvent event,
    Emitter<WardrobeState> emit,
  ) async {
    if (!_hasMoreItems) return;
    emit(
      WardrobeLoadingMoreState(
        _allGroupedItems.map(
          (key, items) =>
              MapEntry(key, items.map(ClothingItemModel.toEntity).toList()),
        ),
        subSubcategories: _subSubcategories,
        categories: _categoriesList,
        subcategories: _subcategories,
      ),
    );
    try {
      final newItems = await _remoteDataSource.getWardrobeItems(
        username: event.username,
        category: event.category,
        subcategory: event.subcategory,
        subSubcategory: event.subSubcategory,
        page: event.page,
        limit: event.limit,
      );
      _allGroupedItems[event.subSubcategory] =
          (_allGroupedItems[event.subSubcategory] ?? [])..addAll(newItems);
      _currentPage = event.page;
      _hasMoreItems = newItems.length == event.limit;
      emit(
        WardrobeLoadedState(
          _allGroupedItems.map(
            (key, items) =>
                MapEntry(key, items.map(ClothingItemModel.toEntity).toList()),
          ),
          hasMoreItems: _hasMoreItems,
          subSubcategories: _subSubcategories,
          categories: _categoriesList,
          subcategories: _subcategories,
        ),
      );
    } catch (e) {
      emit(
        WardrobeErrorState(
          'Не удалось загрузить больше элементов: $e',
          subSubcategories: _subSubcategories,
          categories: _categoriesList,
          subcategories: _subcategories,
        ),
      );
    }
  }

  Future<void> _onFilterWardrobe(
    FilterWardrobeByCategoryEvent event,
    Emitter<WardrobeState> emit,
  ) async {
    emit(
      WardrobeLoadingState(
        subSubcategories: _subSubcategories,
        categories: _categoriesList,
        subcategories: _subcategories,
      ),
    );
    try {
      final filteredItems = await _remoteDataSource.filterWardrobeByCategory(
        category: event.category,
        subcategory: event.subcategory,
        filter: event.filter,
      );
      emit(
        WardrobeFilteredState(
          {
            event.subcategory:
                filteredItems.map(ClothingItemModel.toEntity).toList(),
          },
          subSubcategories: _subSubcategories,
          categories: _categoriesList,
          subcategories: _subcategories,
        ),
      );
    } catch (e) {
      emit(
        WardrobeErrorState(
          'Не удалось отфильтровать гардероб: $e',
          subSubcategories: _subSubcategories,
          categories: _categoriesList,
          subcategories: _subcategories,
        ),
      );
    }
  }

  Future<void> _onDeleteClothingItem(
    DeleteClothingItemEvent event,
    Emitter<WardrobeState> emit,
  ) async {
    emit(
      WardrobeLoadingState(
        subSubcategories: _subSubcategories,
        categories: _categoriesList,
        subcategories: _subcategories,
      ),
    );
    try {
      await _remoteDataSource.deleteClothingItem(event.id);
      _allGroupedItems.forEach((subSubcategory, items) {
        items.removeWhere((item) => item.id == event.id);
      });
      emit(
        WardrobeLoadedState(
          _allGroupedItems.map(
            (key, items) =>
                MapEntry(key, items.map(ClothingItemModel.toEntity).toList()),
          ),
          hasMoreItems: _hasMoreItems,
          subSubcategories: _subSubcategories,
          categories: _categoriesList,
          subcategories: _subcategories,
        ),
      );
    } catch (e) {
      emit(
        WardrobeErrorState(
          'Не удалось удалить элемент: $e',
          subSubcategories: _subSubcategories,
          categories: _categoriesList,
          subcategories: _subcategories,
        ),
      );
    }
  }

  Future<void> _onAddWardrobeItem(
    AddWardrobeItemEvent event,
    Emitter<WardrobeState> emit,
  ) async {
    try {
      final itemModel = ClothingItemModel.fromEntity(event.item);
      await _remoteDataSource.addWardrobeItem(itemModel);
      final subSubcategory = event.item.subSubcategory;
      _allGroupedItems[subSubcategory] =
          (_allGroupedItems[subSubcategory] ?? [])..add(itemModel);
      emit(
        WardrobeLoadedState(
          _allGroupedItems.map(
            (key, items) =>
                MapEntry(key, items.map(ClothingItemModel.toEntity).toList()),
          ),
          hasMoreItems: _hasMoreItems,
          subSubcategories: _subSubcategories,
          categories: _categoriesList,
          subcategories: _subcategories,
        ),
      );
    } catch (e) {
      emit(
        WardrobeErrorState(
          'Не удалось добавить элемент: $e',
          subSubcategories: _subSubcategories,
          categories: _categoriesList,
          subcategories: _subcategories,
        ),
      );
    }
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<WardrobeState> emit,
  ) async {
    _categoriesList = categories.keys.toList();
    emit(
      CategoriesLoadedState(
        categories: _categoriesList,
        subSubcategories: _subSubcategories,
        subcategories: _subcategories,
      ),
    );
  }

  Future<void> _onLoadSubcategories(
    LoadSubcategoriesEvent event,
    Emitter<WardrobeState> emit,
  ) async {
    _subcategories = categories[event.category]?.keys.toList() ?? [];
    emit(
      SubcategoriesLoadedState(
        subcategories: _subcategories,
        subSubcategories: _subSubcategories,
        categories: _categoriesList,
      ),
    );
  }

  Future<void> _onLoadSubSubcategories(
    LoadSubSubcategoriesEvent event,
    Emitter<WardrobeState> emit,
  ) async {
    _subSubcategories = categories[event.category]?[event.subcategory] ?? [];
    emit(
      SubSubcategoriesLoadedState(
        subSubcategories: _subSubcategories,
        subcategories: _subcategories,
        categories: _categoriesList,
      ),
    );
  }

  Future<void> _onSearchSubSubcategory(
    SearchSubSubcategoryEvent event,
    Emitter<WardrobeState> emit,
  ) async {
    emit(
      WardrobeLoadingState(
        subSubcategories: _subSubcategories,
        categories: _categoriesList,
        subcategories: _subcategories,
      ),
    );
    try {
      String? foundCategory, foundSubcategory, foundSubSubcategory;
      for (final category in categories.keys) {
        for (final subcategory in categories[category]!.keys) {
          for (final subSubcategory in categories[category]![subcategory]!) {
            if (subSubcategory.toLowerCase().contains(
              event.query.toLowerCase(),
            )) {
              foundCategory = category;
              foundSubcategory = subcategory;
              foundSubSubcategory = subSubcategory;
              break;
            }
          }
          if (foundSubSubcategory != null) break;
        }
        if (foundSubSubcategory != null) break;
      }
      if (foundCategory != null &&
          foundSubcategory != null &&
          foundSubSubcategory != null) {
        emit(
          SearchResultState(
            category: foundCategory,
            subcategory: foundSubcategory,
            subSubcategory: foundSubSubcategory,
            subSubcategories: _subSubcategories,
            categories: _categoriesList,
            subcategories: _subcategories,
          ),
        );
      } else {
        emit(
          WardrobeErrorState(
            'Под-подкатегория не найдена',
            subSubcategories: _subSubcategories,
            categories: _categoriesList,
            subcategories: _subcategories,
          ),
        );
      }
    } catch (e) {
      emit(
        WardrobeErrorState(
          'Ошибка при поиске: $e',
          subSubcategories: _subSubcategories,
          categories: _categoriesList,
          subcategories: _subcategories,
        ),
      );
    }
  }

  Future<void> _onLoadAllSubSubcategories(
    LoadAllSubSubcategoriesEvent event,
    Emitter<WardrobeState> emit,
  ) async {
    try {
      final List<Map<String, String>> allSubSubcategories = [];
      for (final category in categories.keys) {
        for (final subcategory in categories[category]!.keys) {
          for (final subSubcategory in categories[category]![subcategory]!) {
            allSubSubcategories.add({
              'category': category,
              'subcategory': subcategory,
              'subSubcategory': subSubcategory,
            });
          }
        }
      }
      emit(
        AllSubSubcategoriesLoadedState(
          allSubSubcategories: allSubSubcategories,
          subSubcategories: _subSubcategories,
          categories: _categoriesList,
          subcategories: _subcategories,
        ),
      );
    } catch (e) {
      emit(
        WardrobeErrorState(
          'Ошибка при загрузке под-подкатегорий: $e',
          subSubcategories: _subSubcategories,
          categories: _categoriesList,
          subcategories: _subcategories,
        ),
      );
    }
  }
}
