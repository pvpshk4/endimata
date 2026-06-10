import 'dart:io';
import 'package:endimata/common/data/models/photo_response.dart';
import 'package:endimata/common/data/models/human_photo_response.dart';
import 'dart:convert';

import '../../../../AppData/data/data_sources/remote/app_data_api_service.dart';

abstract class PhotoRemoteDataSource {
  Future<PhotoResponse> uploadClothesPhoto(
    File file,
    String username,
    String category,
    String subcategory,
    String subSubcategory,
  );

  Future<HumanPhotoResponse> uploadHumanPhoto(File file, String username);
}

class PhotoRemoteDataSourceImpl implements PhotoRemoteDataSource {
  final AppDataApiService _apiService;

  PhotoRemoteDataSourceImpl({required AppDataApiService apiService})
    : _apiService = apiService;

  @override
  Future<PhotoResponse> uploadClothesPhoto(
    File file,
    String username,
    String category,
    String subcategory,
    String subSubcategory,
  ) async {
    try {
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      await _apiService.addClothingItem(
        base64Image,
        username,
        category,
        subcategory,
        subSubcategory,
      );

      return PhotoResponse(
        status: 'success',
        message: 'Clothes photo uploaded successfully',
      );
    } catch (e) {
      throw Exception('Failed to upload clothes photo: $e');
    }
  }

  @override
  Future<HumanPhotoResponse> uploadHumanPhoto(
    File file,
    String username,
  ) async {
    try {
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      await _apiService.addHumanPhoto(base64Image, username);

      return HumanPhotoResponse(
        status: 'success',
        message: 'Human photo processed successfully',
        imageBase64: 'data:image/png;base64,$base64Image',
      );
    } catch (e) {
      throw Exception('Failed to upload human photo: $e');
    }
  }
}
