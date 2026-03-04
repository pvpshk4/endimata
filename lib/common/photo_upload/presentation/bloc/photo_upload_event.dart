import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class PhotoUploadEvent extends Equatable {
  const PhotoUploadEvent();

  @override
  List<Object?> get props => [];
}

class SetUploadTypeEvent extends PhotoUploadEvent {
  final bool isClothesUpload;

  const SetUploadTypeEvent(this.isClothesUpload);

  @override
  List<Object?> get props => [isClothesUpload];
}

class TakePhotoFromCameraEvent extends PhotoUploadEvent {}

class TakePhotoFromCameraWithFileEvent extends PhotoUploadEvent {
  final String filePath;
  const TakePhotoFromCameraWithFileEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class ChoosePhotoFromGalleryEvent extends PhotoUploadEvent {}

class CancelPhotoUploadEvent extends PhotoUploadEvent {}

class SelectCategoryEvent extends PhotoUploadEvent {
  final String category;
  final String subcategory;
  final String subSubcategory;

  const SelectCategoryEvent({
    required this.category,
    required this.subcategory,
    required this.subSubcategory,
  });

  @override
  List<Object?> get props => [category, subcategory, subSubcategory];
}

class SavePhotoEvent extends PhotoUploadEvent {
  final BuildContext context;

  const SavePhotoEvent(this.context);

  @override
  List<Object?> get props => [context];
}

class ResetPhotoUploadEvent extends PhotoUploadEvent {}
