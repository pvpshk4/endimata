import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:endimata/common/AppData/domain/repositories/app_data_repository.dart';
import 'package:endimata/common/AppData/presentation/bloc/app_data_event.dart';
import 'package:endimata/common/AppData/presentation/bloc/app_data_state.dart';

class AppDataBloc extends Bloc<AppDataEvent, AppDataState> {
  // НЕ final — чтобы можно было переключить на Flask сервис
  AppDataRepository _repository;
  final SharedPreferences _prefs;

  AppDataBloc(this._repository, this._prefs) : super(const AppDataState()) {
    on<LoadAppDataEvent>(_onLoadAppData);
    on<AddHumanPhotoEvent>(_onAddHumanPhoto);
    on<AddWardrobeItemEvent>(_onAddWardrobeItem);
    on<LoadDeletedPhotosEvent>(_onLoadDeletedPhotos);
    on<DeletePhotosEvent>(_onDeletePhotos);
    on<SelectPhotoEvent>(_onSelectPhoto);
    on<DeselectPhotoEvent>(_onDeselectPhoto);
    on<ClearSelectionEvent>(_onClearSelection);
    on<SelectAllPhotosEvent>(_onSelectAllPhotos);
    on<PermanentlyDeletePhotosEvent>(_onPermanentlyDeletePhotos);
    on<RestorePhotosEvent>(_onRestorePhotos);
    on<SetSelectedPhotoEvent>(_onSetSelectedPhoto);
    on<UpdateRepositoryEvent>(_onUpdateRepository);

    add(const LoadAppDataEvent());
  }

  /// Переключает репозиторий (вызывается из injection_container при входе/выходе)
  void updateRepository(AppDataRepository newRepository) {
    add(UpdateRepositoryEvent(newRepository));
  }

  Future<void> _onUpdateRepository(
    UpdateRepositoryEvent event,
    Emitter<AppDataState> emit,
  ) async {
    _repository = event.repository;
    // Перезагружаем данные с новым сервисом
    add(const LoadAppDataEvent());
  }

  Future<void> _onLoadAppData(
    LoadAppDataEvent event,
    Emitter<AppDataState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final humanPhotos = await _repository.getHumanPhotos();
      final catalogItems = await _repository.getCatalogItems();
      final wardrobeItems = await _repository.getWardrobeItems();
      final deletedPhotos = await _repository.getDeletedPhotos();

      final savedSelectedPhoto = _prefs.getString('selectedHumanPhoto');
      final updatedSelected =
          savedSelectedPhoto != null && humanPhotos.contains(savedSelectedPhoto)
              ? savedSelectedPhoto
              : null;

      emit(
        state.copyWith(
          humanPhotos: humanPhotos,
          catalogItems: catalogItems,
          wardrobeItems: wardrobeItems,
          deletedPhotos: deletedPhotos,
          selectedHumanPhoto: updatedSelected,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Не удалось загрузить данные: $e',
        ),
      );
    }
  }

  Future<void> _onAddHumanPhoto(
    AddHumanPhotoEvent event,
    Emitter<AppDataState> emit,
  ) async {
    print('📸 _onAddHumanPhoto вызван, userName: ${event.userName}');
    print('📦 Текущий репозиторий: ${_repository.runtimeType}');
    await _repository.addHumanPhoto(event.photoBase64, event.userName);
    add(const LoadAppDataEvent());
  }

  Future<void> _onAddWardrobeItem(
    AddWardrobeItemEvent event,
    Emitter<AppDataState> emit,
  ) async {
    await _repository.addClothingItem(
      event.fileBase64,
      event.userName,
      event.category,
      event.subcategory,
      event.subSubcategory,
    );
    add(const LoadAppDataEvent());
  }

  Future<void> _onLoadDeletedPhotos(
    LoadDeletedPhotosEvent event,
    Emitter<AppDataState> emit,
  ) async {
    try {
      final deletedPhotos = await _repository.getDeletedPhotos();
      emit(state.copyWith(deletedPhotos: deletedPhotos));
    } catch (e) {
      emit(
        state.copyWith(error: 'Не удалось загрузить удалённые фотографии: $e'),
      );
    }
  }

  Future<void> _onDeletePhotos(
    DeletePhotosEvent event,
    Emitter<AppDataState> emit,
  ) async {
    try {
      for (var photo in event.photos) {
        final id = photo.hashCode.toString();
        await _repository.deletePhoto(id, 'human');
      }
      final updatedHumanPhotos = await _repository.getHumanPhotos();
      final updatedDeletedPhotos = await _repository.getDeletedPhotos();
      final currentSelected = state.selectedHumanPhoto;
      final updatedSelected =
          currentSelected != null &&
                  updatedHumanPhotos.contains(currentSelected)
              ? currentSelected
              : null;

      if (updatedSelected == null && currentSelected != null) {
        await _prefs.remove('selectedHumanPhoto');
      }

      emit(
        state.copyWith(
          humanPhotos: updatedHumanPhotos,
          deletedPhotos: updatedDeletedPhotos,
          selectedHumanPhoto: updatedSelected,
          selectedHumanPhotos: const {},
        ),
      );

      add(const LoadAppDataEvent());
    } catch (e) {
      emit(state.copyWith(error: 'Не удалось удалить фотографии: $e'));
    }
  }

  void _onSelectPhoto(SelectPhotoEvent event, Emitter<AppDataState> emit) {
    if (event.isDeletedPhotos) {
      final updatedSelection = Set<String>.from(state.selectedDeletedPhotos);
      updatedSelection.add(event.photo);
      emit(state.copyWith(selectedDeletedPhotos: updatedSelection));
    } else {
      final updatedSelection = Set<String>.from(state.selectedHumanPhotos);
      updatedSelection.add(event.photo);
      emit(state.copyWith(selectedHumanPhotos: updatedSelection));
    }
  }

  void _onDeselectPhoto(DeselectPhotoEvent event, Emitter<AppDataState> emit) {
    if (event.isDeletedPhotos) {
      final updatedSelection = Set<String>.from(state.selectedDeletedPhotos);
      updatedSelection.remove(event.photo);
      emit(state.copyWith(selectedDeletedPhotos: updatedSelection));
    } else {
      final updatedSelection = Set<String>.from(state.selectedHumanPhotos);
      updatedSelection.remove(event.photo);
      emit(state.copyWith(selectedHumanPhotos: updatedSelection));
    }
  }

  void _onClearSelection(
    ClearSelectionEvent event,
    Emitter<AppDataState> emit,
  ) {
    if (event.isDeletedPhotos) {
      emit(state.copyWith(selectedDeletedPhotos: const {}));
    } else {
      emit(state.copyWith(selectedHumanPhotos: const {}));
    }
  }

  void _onSelectAllPhotos(
    SelectAllPhotosEvent event,
    Emitter<AppDataState> emit,
  ) {
    if (event.isDeletedPhotos) {
      emit(
        state.copyWith(selectedDeletedPhotos: Set<String>.from(event.photos)),
      );
    } else {
      emit(state.copyWith(selectedHumanPhotos: Set<String>.from(event.photos)));
    }
  }

  Future<void> _onPermanentlyDeletePhotos(
    PermanentlyDeletePhotosEvent event,
    Emitter<AppDataState> emit,
  ) async {
    try {
      for (var photo in event.photos) {
        await _repository.permanentlyDeletePhoto(photo);
      }
      final updatedDeletedPhotos = await _repository.getDeletedPhotos();
      final updatedHumanPhotos = await _repository.getHumanPhotos();
      final currentSelected = state.selectedHumanPhoto;
      final updatedSelected =
          currentSelected != null &&
                  updatedHumanPhotos.contains(currentSelected)
              ? currentSelected
              : null;

      if (updatedSelected == null && currentSelected != null) {
        await _prefs.remove('selectedHumanPhoto');
      }

      emit(
        state.copyWith(
          humanPhotos: updatedHumanPhotos,
          deletedPhotos: updatedDeletedPhotos,
          selectedDeletedPhotos: const {},
          selectedHumanPhoto: updatedSelected,
        ),
      );

      add(const LoadAppDataEvent());
    } catch (e) {
      emit(
        state.copyWith(error: 'Не удалось окончательно удалить фотографии: $e'),
      );
    }
  }

  Future<void> _onRestorePhotos(
    RestorePhotosEvent event,
    Emitter<AppDataState> emit,
  ) async {
    try {
      final deletedPhotos = await _repository.getDeletedPhotos();
      for (var photo in event.photos) {
        final deletedPhoto = deletedPhotos.firstWhere(
          (p) => p.imageBase64 == photo,
        );
        if (deletedPhoto.type == 'human') {
          await _repository.addHumanPhoto(
            deletedPhoto.imageBase64,
            deletedPhoto.userName,
          );
        } else if (deletedPhoto.type == 'wardrobe') {
          await _repository.addClothingItem(
            deletedPhoto.imageBase64,
            deletedPhoto.userName,
            deletedPhoto.category ?? '',
            deletedPhoto.subcategory ?? '',
            deletedPhoto.subSubcategory ?? '',
          );
        }
        await _repository.permanentlyDeletePhoto(photo);
      }
      final updatedHumanPhotos = await _repository.getHumanPhotos();
      final updatedWardrobeItems = await _repository.getWardrobeItems();
      final updatedDeletedPhotos = await _repository.getDeletedPhotos();
      final currentSelected = state.selectedHumanPhoto;
      final updatedSelected =
          currentSelected != null &&
                  updatedHumanPhotos.contains(currentSelected)
              ? currentSelected
              : null;

      if (updatedSelected == null && currentSelected != null) {
        await _prefs.remove('selectedHumanPhoto');
      }

      emit(
        state.copyWith(
          humanPhotos: updatedHumanPhotos,
          wardrobeItems: updatedWardrobeItems,
          deletedPhotos: updatedDeletedPhotos,
          selectedDeletedPhotos: const {},
          selectedHumanPhoto: updatedSelected,
        ),
      );

      add(const LoadAppDataEvent());
    } catch (e) {
      emit(state.copyWith(error: 'Не удалось восстановить фотографии: $e'));
    }
  }

  Future<void> _onSetSelectedPhoto(
    SetSelectedPhotoEvent event,
    Emitter<AppDataState> emit,
  ) async {
    emit(state.copyWith(selectedHumanPhoto: event.photo));
    if (event.photo != null) {
      await _prefs.setString('selectedHumanPhoto', event.photo!);
    } else {
      await _prefs.remove('selectedHumanPhoto');
    }
  }
}
