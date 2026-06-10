import 'dart:io';
import 'dart:convert';
import 'package:endimata/common/photo_upload/domain/entities/photo_entity.dart';
import 'package:endimata/common/photo_upload/data/data_sources/remote/photo_remote_data_source.dart';
import '../../domain/repositories/photo_repository.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  final PhotoRemoteDataSource remoteDataSource;

  PhotoRepositoryImpl(this.remoteDataSource);

  @override
  Future<PhotoEntity> uploadClothesPhoto(
    File file,
    String username,
    String category,
    String subcategory,
    String subSubcategory,
  ) async {
    final response = await remoteDataSource.uploadClothesPhoto(
      file,
      username,
      category,
      subcategory,
      subSubcategory,
    );
    if (response.status == 'success') {
      // Сервер не возвращает image_base64, используем исходное изображение
      final base64Image = base64Encode(await file.readAsBytes());
      return PhotoEntity(
        user_name: username,
        image: base64Image,
        category: category,
        subcategory: subcategory,
        sub_subcategory: subSubcategory,
      );
    } else {
      throw Exception(response.message);
    }
  }

  @override
  Future<PhotoEntity> uploadHumanPhoto(File file, String username) async {
    final response = await remoteDataSource.uploadHumanPhoto(file, username);
    if (response.status == 'success') {
      return PhotoEntity(
        user_name: username,
        image:
            response.imageBase64
                .split(',')
                .last, // Убираем префикс "data:image/png;base64,"
        category: 'full',
        subcategory: '',
        sub_subcategory: '',
      );
    } else {
      throw Exception(response.message);
    }
  }
}
