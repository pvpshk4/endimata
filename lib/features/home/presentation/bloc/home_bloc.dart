import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:endimata/common/AppData/presentation/bloc/app_data_bloc.dart';
import 'package:endimata/common/AppData/data/models/photo_model.dart';
import 'package:endimata/common/AppData/data/data_sources/remote/flask_app_data_service.dart';
import '../../../../common/utils/debug_logger.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AppDataBloc appDataBloc;
  Timer? _tryOnPollingTimer;

  HomeBloc(this.appDataBloc) : super(const HomeInitialState()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<SelectCategoryEvent>(_onSelectCategory);
    on<SelectSubcategoryEvent>(_onSelectSubcategory);
    on<SelectSubSubcategoryEvent>(_onSelectSubSubcategory);
    on<ResetFilterEvent>(_onResetFilter);
    on<GoToPreviousEvent>(_onGoToPrevious);
    on<StartTryOnEvent>(_onStartTryOn);
    on<CheckTryOnStatusEvent>(_onCheckTryOnStatus);
    on<ClearTryOnEvent>(_onClearTryOn);

    add(LoadHomeDataEvent());
  }

  @override
  Future<void> close() {
    _tryOnPollingTimer?.cancel();
    return super.close();
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
      emit(const HomeErrorState('Данные ещё загружаются'));
      return;
    }

    if (appDataState.error != null) {
      emit(HomeErrorState(appDataState.error!));
      return;
    }

    emit(
      HomeLoadedState(
        catalogItems: appDataState.catalogItems,
        wardrobeItems: appDataState.wardrobeItems,
      ),
    );
  }

  // ──────────────────────── TRYON ────────────────────────

  Future<void> _onStartTryOn(
    StartTryOnEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Нужно фото человека
    final selectedPhoto = appDataBloc.state.selectedHumanPhoto;
    if (selectedPhoto == null || selectedPhoto.isEmpty) {
      emit(
        _currentLoadedState().copyWithTryOn(
          tryOnStatus: TryOnStatus.error,
          tryOnError: 'Сначала выберите фото человека',
        ),
      );
      return;
    }

    emit(
      _currentLoadedState().copyWithTryOn(
        tryOnStatus: TryOnStatus.loading,
        tryOnTaskId: null,
        tryOnResultBase64: null,
        tryOnError: null,
      ),
    );

    try {
      // Получаем FlaskAppDataService из репозитория
      final flaskService = _getFlaskService();
      if (flaskService == null) {
        emit(
          _currentLoadedState().copyWithTryOn(
            tryOnStatus: TryOnStatus.error,
            tryOnError: 'Сервер не подключён',
          ),
        );
        return;
      }

      final taskId = await flaskService.startTryon(
        personImageBase64: selectedPhoto,
        clothImageBase64: event.clothImageBase64,
        clothType: event.clothType,
      );

      if (taskId == null) {
        emit(
          _currentLoadedState().copyWithTryOn(
            tryOnStatus: TryOnStatus.error,
            tryOnError: 'Не удалось запустить примерку',
          ),
        );
        return;
      }

      emit(
        _currentLoadedState().copyWithTryOn(
          tryOnStatus: TryOnStatus.loading,
          tryOnTaskId: taskId,
        ),
      );

      // Запускаем polling каждые 5 секунд
      _tryOnPollingTimer?.cancel();
      _tryOnPollingTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => add(CheckTryOnStatusEvent(taskId)),
      );
    } catch (e) {
      emit(
        _currentLoadedState().copyWithTryOn(
          tryOnStatus: TryOnStatus.error,
          tryOnError: 'Ошибка: $e',
        ),
      );
    }
  }

  Future<void> _onCheckTryOnStatus(
    CheckTryOnStatusEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final flaskService = _getFlaskService();
      if (flaskService == null) return;

      final result = await flaskService.getTryonStatus(event.taskId);
      if (result == null) return;

      final status = result['status'] as String?;

      if (status == 'done') {
        _tryOnPollingTimer?.cancel();
        final resultBase64 = result['result_base64'] as String?;
        emit(
          _currentLoadedState().copyWithTryOn(
            tryOnStatus: TryOnStatus.done,
            tryOnResultBase64: resultBase64,
            tryOnTaskId: null,
          ),
        );
      } else if (status == 'error') {
        _tryOnPollingTimer?.cancel();
        emit(
          _currentLoadedState().copyWithTryOn(
            tryOnStatus: TryOnStatus.error,
            tryOnError: result['message'] ?? 'Ошибка примерки',
            tryOnTaskId: null,
          ),
        );
      }
      // queued/processing — продолжаем polling
    } catch (e) {
      // Не прерываем polling из-за единичной ошибки
      print('Ошибка polling: $e');
    }
  }

  void _onClearTryOn(ClearTryOnEvent event, Emitter<HomeState> emit) {
    _tryOnPollingTimer?.cancel();
    emit(
      _currentLoadedState().copyWithTryOn(
        tryOnStatus: TryOnStatus.idle,
        tryOnTaskId: null,
        tryOnResultBase64: null,
        tryOnError: null,
      ),
    );
  }

  HomeLoadedState _currentLoadedState() {
    final s = state;
    if (s is HomeLoadedState) return s;
    return HomeLoadedState(
      catalogItems: s.catalogItems,
      wardrobeItems: s.wardrobeItems,
      catalogCategory: s.catalogCategory,
      catalogSubcategory: s.catalogSubcategory,
      catalogSubSubcategory: s.catalogSubSubcategory,
      wardrobeCategory: s.wardrobeCategory,
      wardrobeSubcategory: s.wardrobeSubcategory,
      wardrobeSubSubcategory: s.wardrobeSubSubcategory,
      tryOnStatus: s.tryOnStatus,
      tryOnTaskId: s.tryOnTaskId,
      tryOnResultBase64: s.tryOnResultBase64,
    );
  }

  FlaskAppDataService? _getFlaskService() {
    try {
      // AppDataBloc.repository — публичный getter который нужно добавить
      // В AppDataRepository._apiService хранится FlaskAppDataService
      final repo = appDataBloc.repository;
      final apiService = repo.apiService;
      if (apiService is FlaskAppDataService) return apiService;
    } catch (e) {
      print('_getFlaskService error: $e');
    }
    return null;
  }

  // ──────────────────────── FILTERS ────────────────────────

  void _onSelectCategory(SelectCategoryEvent event, Emitter<HomeState> emit) {
    final appDataState = appDataBloc.state;

    if (event.isCatalogTab) {
      final filtered = _filterItems(
        items: appDataState.catalogItems,
        category: event.categoryName,
        subcategory: '',
        subSubcategory: '',
      );
      emit(
        HomeCatalogCategorySelectedState(
          catalogItems: filtered,
          wardrobeItems: state.wardrobeItems,
          catalogCategory: event.categoryName,
          wardrobeCategory: state.wardrobeCategory,
          wardrobeSubcategory: state.wardrobeSubcategory,
          wardrobeSubSubcategory: state.wardrobeSubSubcategory,
          tryOnStatus: state.tryOnStatus,
          tryOnTaskId: state.tryOnTaskId,
          tryOnResultBase64: state.tryOnResultBase64,
        ),
      );
    } else {
      final filtered = _filterItems(
        items: appDataState.wardrobeItems,
        category: event.categoryName,
        subcategory: '',
        subSubcategory: '',
      );
      emit(
        HomeWardrobeCategorySelectedState(
          catalogItems: state.catalogItems,
          wardrobeItems: filtered,
          wardrobeCategory: event.categoryName,
          catalogCategory: state.catalogCategory,
          catalogSubcategory: state.catalogSubcategory,
          catalogSubSubcategory: state.catalogSubSubcategory,
          tryOnStatus: state.tryOnStatus,
          tryOnTaskId: state.tryOnTaskId,
          tryOnResultBase64: state.tryOnResultBase64,
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
      final filtered = _filterItems(
        items: appDataState.catalogItems,
        category: state.catalogCategory,
        subcategory: event.subcategoryName,
        subSubcategory: '',
      );
      emit(
        HomeCatalogSubcategorySelectedState(
          catalogItems: filtered,
          wardrobeItems: state.wardrobeItems,
          catalogCategory: state.catalogCategory,
          catalogSubcategory: event.subcategoryName,
          wardrobeCategory: state.wardrobeCategory,
          wardrobeSubcategory: state.wardrobeSubcategory,
          wardrobeSubSubcategory: state.wardrobeSubSubcategory,
          tryOnStatus: state.tryOnStatus,
          tryOnTaskId: state.tryOnTaskId,
          tryOnResultBase64: state.tryOnResultBase64,
        ),
      );
    } else {
      final filtered = _filterItems(
        items: appDataState.wardrobeItems,
        category: state.wardrobeCategory,
        subcategory: event.subcategoryName,
        subSubcategory: '',
      );
      emit(
        HomeWardrobeSubcategorySelectedState(
          catalogItems: state.catalogItems,
          wardrobeItems: filtered,
          wardrobeCategory: state.wardrobeCategory,
          wardrobeSubcategory: event.subcategoryName,
          catalogCategory: state.catalogCategory,
          catalogSubcategory: state.catalogSubcategory,
          catalogSubSubcategory: state.catalogSubSubcategory,
          tryOnStatus: state.tryOnStatus,
          tryOnTaskId: state.tryOnTaskId,
          tryOnResultBase64: state.tryOnResultBase64,
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
      final filtered = _filterItems(
        items: appDataState.catalogItems,
        category: state.catalogCategory,
        subcategory: state.catalogSubcategory,
        subSubcategory: event.subSubcategoryName,
      );
      emit(
        HomeCatalogSubSubcategorySelectedState(
          catalogItems: filtered,
          wardrobeItems: state.wardrobeItems,
          catalogCategory: state.catalogCategory,
          catalogSubcategory: state.catalogSubcategory,
          catalogSubSubcategory: event.subSubcategoryName,
          wardrobeCategory: state.wardrobeCategory,
          wardrobeSubcategory: state.wardrobeSubcategory,
          wardrobeSubSubcategory: state.wardrobeSubSubcategory,
          tryOnStatus: state.tryOnStatus,
          tryOnTaskId: state.tryOnTaskId,
          tryOnResultBase64: state.tryOnResultBase64,
        ),
      );
    } else {
      final filtered = _filterItems(
        items: appDataState.wardrobeItems,
        category: state.wardrobeCategory,
        subcategory: state.wardrobeSubcategory,
        subSubcategory: event.subSubcategoryName,
      );
      emit(
        HomeWardrobeSubSubcategorySelectedState(
          catalogItems: state.catalogItems,
          wardrobeItems: filtered,
          wardrobeCategory: state.wardrobeCategory,
          wardrobeSubcategory: state.wardrobeSubcategory,
          wardrobeSubSubcategory: event.subSubcategoryName,
          catalogCategory: state.catalogCategory,
          catalogSubcategory: state.catalogSubcategory,
          catalogSubSubcategory: state.catalogSubSubcategory,
          tryOnStatus: state.tryOnStatus,
          tryOnTaskId: state.tryOnTaskId,
          tryOnResultBase64: state.tryOnResultBase64,
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
          wardrobeCategory: state.wardrobeCategory,
          wardrobeSubcategory: state.wardrobeSubcategory,
          wardrobeSubSubcategory: state.wardrobeSubSubcategory,
          tryOnStatus: state.tryOnStatus,
          tryOnTaskId: state.tryOnTaskId,
          tryOnResultBase64: state.tryOnResultBase64,
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
          tryOnStatus: state.tryOnStatus,
          tryOnTaskId: state.tryOnTaskId,
          tryOnResultBase64: state.tryOnResultBase64,
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
            wardrobeCategory: state.wardrobeCategory,
            wardrobeSubcategory: state.wardrobeSubcategory,
            wardrobeSubSubcategory: state.wardrobeSubSubcategory,
            tryOnStatus: state.tryOnStatus,
            tryOnTaskId: state.tryOnTaskId,
            tryOnResultBase64: state.tryOnResultBase64,
          ),
        );
      } else if (event.level == 1) {
        final filtered = _filterItems(
          items: appDataState.catalogItems,
          category: state.catalogCategory,
          subcategory: '',
          subSubcategory: '',
        );
        emit(
          HomeCatalogCategorySelectedState(
            catalogItems: filtered,
            wardrobeItems: state.wardrobeItems,
            catalogCategory: state.catalogCategory,
            wardrobeCategory: state.wardrobeCategory,
            wardrobeSubcategory: state.wardrobeSubcategory,
            wardrobeSubSubcategory: state.wardrobeSubSubcategory,
            tryOnStatus: state.tryOnStatus,
            tryOnTaskId: state.tryOnTaskId,
            tryOnResultBase64: state.tryOnResultBase64,
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
            tryOnStatus: state.tryOnStatus,
            tryOnTaskId: state.tryOnTaskId,
            tryOnResultBase64: state.tryOnResultBase64,
          ),
        );
      } else if (event.level == 1) {
        final filtered = _filterItems(
          items: appDataState.wardrobeItems,
          category: state.wardrobeCategory,
          subcategory: '',
          subSubcategory: '',
        );
        emit(
          HomeWardrobeCategorySelectedState(
            catalogItems: state.catalogItems,
            wardrobeItems: filtered,
            wardrobeCategory: state.wardrobeCategory,
            catalogCategory: state.catalogCategory,
            catalogSubcategory: state.catalogSubcategory,
            catalogSubSubcategory: state.catalogSubSubcategory,
            tryOnStatus: state.tryOnStatus,
            tryOnTaskId: state.tryOnTaskId,
            tryOnResultBase64: state.tryOnResultBase64,
          ),
        );
      }
    }
  }
}
