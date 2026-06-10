import 'package:equatable/equatable.dart';
import 'package:endimata/common/photo_upload/domain/entities/photo_entity.dart';

abstract class PhotoUploadState extends Equatable {
  const PhotoUploadState();

  @override
  List<Object?> get props => [];
}

class PhotoUploadInitialState extends PhotoUploadState {}

class PhotoUploadLoadingState extends PhotoUploadState {}

class PhotoUploadSuccessState extends PhotoUploadState {
  final PhotoEntity photo;

  const PhotoUploadSuccessState(this.photo);

  @override
  List<Object?> get props => [photo];
}

class PhotoUploadFailureState extends PhotoUploadState {
  final String message;

  const PhotoUploadFailureState(this.message);

  @override
  List<Object?> get props => [message];
}

class PhotoUploadAwaitingCategoryState extends PhotoUploadState {
  final String imagePath;

  const PhotoUploadAwaitingCategoryState(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class PhotoUploadPreviewState extends PhotoUploadState {
  final String imagePath;

  const PhotoUploadPreviewState(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class PhotoUploadResetState extends PhotoUploadState {}
