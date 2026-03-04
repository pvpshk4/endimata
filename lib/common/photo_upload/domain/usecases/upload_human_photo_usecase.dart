import 'dart:io';
import 'package:endimata/common/photo_upload/domain/entities/photo_entity.dart';
import '../repositories/photo_repository.dart';

class UploadHumanPhotoUsecase {
  final PhotoRepository uploadPhotoRepository;

  UploadHumanPhotoUsecase(this.uploadPhotoRepository);

  Future<PhotoEntity> call(File file, String username) async {
    return await uploadPhotoRepository.uploadHumanPhoto(file, username);
  }
}
