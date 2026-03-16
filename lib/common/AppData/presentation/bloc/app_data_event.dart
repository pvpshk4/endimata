import 'package:equatable/equatable.dart';
import 'package:endimata/common/AppData/domain/repositories/app_data_repository.dart';

abstract class AppDataEvent extends Equatable {
  const AppDataEvent();

  @override
  List<Object?> get props => [];
}

class LoadAppDataEvent extends AppDataEvent {
  const LoadAppDataEvent();
}

/// Переключает репозиторий — используется при входе/выходе пользователя
class UpdateRepositoryEvent extends AppDataEvent {
  final AppDataRepository repository;
  const UpdateRepositoryEvent(this.repository);

  @override
  List<Object?> get props => [repository];
}

class AddHumanPhotoEvent extends AppDataEvent {
  final String photoBase64;
  final String userName;

  const AddHumanPhotoEvent({required this.photoBase64, required this.userName});

  @override
  List<Object?> get props => [photoBase64, userName];
}

class AddWardrobeItemEvent extends AppDataEvent {
  final String fileBase64;
  final String userName;
  final String category;
  final String subcategory;
  final String subSubcategory;

  const AddWardrobeItemEvent({
    required this.fileBase64,
    required this.userName,
    required this.category,
    required this.subcategory,
    required this.subSubcategory,
  });

  @override
  List<Object?> get props => [
    fileBase64,
    userName,
    category,
    subcategory,
    subSubcategory,
  ];
}

class LoadDeletedPhotosEvent extends AppDataEvent {
  const LoadDeletedPhotosEvent();
}

class ClearAppDataEvent extends AppDataEvent {}

class DeletePhotosEvent extends AppDataEvent {
  final List<String> photos;

  const DeletePhotosEvent(this.photos);

  @override
  List<Object?> get props => [photos];
}

class SelectPhotoEvent extends AppDataEvent {
  final String photo;
  final bool isDeletedPhotos;

  const SelectPhotoEvent(this.photo, {required this.isDeletedPhotos});

  @override
  List<Object?> get props => [photo, isDeletedPhotos];
}

class DeselectPhotoEvent extends AppDataEvent {
  final String photo;
  final bool isDeletedPhotos;

  const DeselectPhotoEvent(this.photo, {required this.isDeletedPhotos});

  @override
  List<Object?> get props => [photo, isDeletedPhotos];
}

class ClearSelectionEvent extends AppDataEvent {
  final bool isDeletedPhotos;

  const ClearSelectionEvent({required this.isDeletedPhotos});

  @override
  List<Object?> get props => [isDeletedPhotos];
}

class SelectAllPhotosEvent extends AppDataEvent {
  final List<String> photos;
  final bool isDeletedPhotos;

  const SelectAllPhotosEvent(this.photos, {required this.isDeletedPhotos});

  @override
  List<Object?> get props => [photos, isDeletedPhotos];
}

class PermanentlyDeletePhotosEvent extends AppDataEvent {
  final List<String> photos;

  const PermanentlyDeletePhotosEvent(this.photos);

  @override
  List<Object?> get props => [photos];
}

class RestorePhotosEvent extends AppDataEvent {
  final List<String> photos;

  const RestorePhotosEvent(this.photos);

  @override
  List<Object?> get props => [photos];
}

class SetSelectedPhotoEvent extends AppDataEvent {
  final String? photo;

  const SetSelectedPhotoEvent(this.photo);

  @override
  List<Object?> get props => [photo];
}
