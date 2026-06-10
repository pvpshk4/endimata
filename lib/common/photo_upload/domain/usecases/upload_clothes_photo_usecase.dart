import 'dart:io';
import 'package:endimata/common/photo_upload/domain/entities/photo_entity.dart';
import '../repositories/photo_repository.dart';

class UploadClothesPhotoUsecase {
  final PhotoRepository uploadPhotoRepository;

  UploadClothesPhotoUsecase(this.uploadPhotoRepository);

  Future<PhotoEntity> call(
    File file,
    String username,
    String category,
    String subcategory,
    String subSubcategory,
  ) async {
    return await uploadPhotoRepository.uploadClothesPhoto(
      file,
      username,
      category,
      subcategory,
      subSubcategory,
    );
  }
}
