import 'package:equatable/equatable.dart';
import '../../data/models/deleted_photo_model.dart';
import '../../data/models/photo_model.dart';

class AppDataState extends Equatable {
  final List<String> humanPhotos;
  final List<PhotoModel> catalogItems;
  final List<PhotoModel> wardrobeItems;
  final List<DeletedPhotoModel> deletedPhotos;
  final Set<String> selectedHumanPhotos;
  final Set<String> selectedDeletedPhotos;
  final bool isLoading;
  final String? error;
  final String? selectedHumanPhoto;

  const AppDataState({
    this.humanPhotos = const [],
    this.catalogItems = const [],
    this.wardrobeItems = const [],
    this.deletedPhotos = const [],
    this.selectedHumanPhotos = const {},
    this.selectedDeletedPhotos = const {},
    this.isLoading = false,
    this.error,
    this.selectedHumanPhoto,
  });

  AppDataState copyWith({
    List<String>? humanPhotos,
    List<PhotoModel>? catalogItems,
    List<PhotoModel>? wardrobeItems,
    List<DeletedPhotoModel>? deletedPhotos,
    Set<String>? selectedHumanPhotos,
    Set<String>? selectedDeletedPhotos,
    bool? isLoading,
    String? error,
    String? selectedHumanPhoto,
  }) {
    return AppDataState(
      humanPhotos: humanPhotos ?? this.humanPhotos,
      catalogItems: catalogItems ?? this.catalogItems,
      wardrobeItems: wardrobeItems ?? this.wardrobeItems,
      deletedPhotos: deletedPhotos ?? this.deletedPhotos,
      selectedHumanPhotos: selectedHumanPhotos ?? this.selectedHumanPhotos,
      selectedDeletedPhotos:
          selectedDeletedPhotos ?? this.selectedDeletedPhotos,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedHumanPhoto: selectedHumanPhoto ?? this.selectedHumanPhoto,
    );
  }

  @override
  List<Object?> get props => [
    humanPhotos,
    catalogItems,
    wardrobeItems,
    deletedPhotos,
    selectedHumanPhotos,
    selectedDeletedPhotos,
    isLoading,
    error,
    selectedHumanPhoto,
  ];
}
