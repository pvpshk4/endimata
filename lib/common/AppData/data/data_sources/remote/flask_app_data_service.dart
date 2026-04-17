import 'package:dio/dio.dart';
import 'package:endimata/common/utils/debug_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:endimata/common/AppData/data/data_sources/remote/app_data_api_service.dart';
import 'package:endimata/common/AppData/data/models/deleted_photo_model.dart';
import 'package:endimata/common/AppData/data/models/photo_model.dart';

const String kServerBaseUrl = 'http://192.168.3.7:5000';

class FlaskAppDataService implements AppDataApiService {
  late final Dio _dio;

  final Box<String> _humanPhotosBox;
  final Box<PhotoModel> _wardrobeItemsBox;
  final Box<DeletedPhotoModel> _deletedPhotosBox;

  FlaskAppDataService({
    required Box<String> humanPhotosBox,
    required Box<PhotoModel> wardrobeItemsBox,
    required Box<DeletedPhotoModel> deletedPhotosBox,
  }) : _humanPhotosBox = humanPhotosBox,
       _wardrobeItemsBox = wardrobeItemsBox,
       _deletedPhotosBox = deletedPhotosBox {
    _dio = Dio(
      BaseOptions(
        baseUrl: kServerBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 120),
        headers: {'bypass-tunnel-reminder': 'true'},
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => print(o),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getJwtToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final newToken = await _refreshJwtToken();
            if (newToken != null) {
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newToken';
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ──────────────────────── JWT ────────────────────────

  Future<String?> _getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('flask_jwt_token');
  }

  Future<String?> refreshJwtTokenPublic() => _refreshJwtToken();

  Future<String?> _refreshJwtToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final firebaseToken = await user.getIdToken(true);

      final response = await Dio().post(
        '$kServerBaseUrl/auth/login/firebase',
        data: {'firebase_token': firebaseToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'bypass-tunnel-reminder': 'true',
          },
        ),
      );

      if (response.statusCode == 200) {
        final accessToken = response.data['access_token'] as String;
        final idUser = response.data['id_user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('flask_jwt_token', accessToken);
        await prefs.setString('flask_user_id', idUser.toString());

        print('✅ JWT получен, flask_user_id: $idUser');
        return accessToken;
      }
    } catch (e) {
      print('❌ Ошибка refreshJwtToken: $e');
    }
    return null;
  }

  // ──────────────────────── HUMAN PHOTOS ────────────────────────

  @override
  Future<List<String>> getHumanPhotos() async {
    try {
      await _syncHumanPhotosFromServer();
    } catch (e) {
      print('⚠️ Синхронизация не удалась: $e');
    }
    return _humanPhotosBox.values.toList();
  }

  Future<void> _syncHumanPhotosFromServer() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('flask_user_id') ?? '';
    if (userId.isEmpty) return;

    final response = await _dio.get(
      '/human/user_photos/$userId',
      queryParameters: {'page': 1, 'limit': 50},
    );

    if (response.statusCode == 200) {
      final photos = response.data['photos'] as List;
      await _humanPhotosBox.clear();
      for (final photo in photos) {
        final id = photo['id'].toString();
        final base64 = photo['image_base64'] as String;
        final clean = base64.contains(',') ? base64.split(',').last : base64;
        await _humanPhotosBox.put(id, clean);
      }
    }
  }

  @override
  Future<void> addHumanPhoto(String fileBase64, String userName) async {
    print('📸 addHumanPhoto вызван, userName: $userName');
    try {
      final cleanBase64 =
          fileBase64.contains(',') ? fileBase64.split(',').last : fileBase64;

      // Получаем числовой flask_user_id
      final prefs = await SharedPreferences.getInstance();
      final flaskUserId = prefs.getString('flask_user_id');

      final Map<String, dynamic> requestData;
      if (flaskUserId != null && flaskUserId.isNotEmpty) {
        // Отправляем числовой user_id — сервер найдёт пользователя напрямую по id
        requestData = {
          'image': 'data:image/png;base64,$cleanBase64',
          'user_id': int.parse(flaskUserId),
        };
        print('📡 Отправляем с user_id: $flaskUserId');
      } else {
        // Fallback — отправляем user_name
        requestData = {
          'image': 'data:image/png;base64,$cleanBase64',
          'user_name': userName,
        };
        print('📡 Отправляем с user_name: $userName');
      }

      print('📏 Размер base64: ${cleanBase64.length} символов');
      print('📦 requestData keys: ${requestData.keys.toList()}');
      final response = await _dio.post('/human/process', data: requestData);
      print('✅ Ответ сервера: ${response.statusCode}');

      if (response.statusCode == 200) {
        final processedBase64 = response.data['image_base64'] as String?;
        if (processedBase64 != null) {
          final clean =
              processedBase64.contains(',')
                  ? processedBase64.split(',').last
                  : processedBase64;
          await _humanPhotosBox.add(clean);
          print('💾 Фото сохранено в кэш');
        }
      }
    } on DioException catch (e) {
      print('❌ Ошибка addHumanPhoto статус: ${e.response?.statusCode}');
      print('❌ Тело ответа: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ Ошибка addHumanPhoto: $e');
      rethrow;
    }
  }

  // ──────────────────────── WARDROBE ────────────────────────

  @override
  Future<List<PhotoModel>> getWardrobeItems() async {
    return _wardrobeItemsBox.values.toList();
  }

  @override
  Future<void> addClothingItem(
    String fileBase64,
    String userName,
    String category,
    String subcategory,
    String subSubcategory,
  ) async {
    final cleanBase64 =
        fileBase64.contains(',') ? fileBase64.split(',').last : fileBase64;

    final prefs = await SharedPreferences.getInstance();
    final flaskUserId = prefs.getString('flask_user_id');

    final Map<String, dynamic> requestData = {
      'image': cleanBase64,
      'category': category,
      'subcategory': subcategory,
      'sub_subcategory': subSubcategory,
    };

    if (flaskUserId != null && flaskUserId.isNotEmpty) {
      requestData['user_id'] = int.parse(flaskUserId);
    } else {
      requestData['user_name'] = userName;
    }

    print(
      '📡 Отправляем одежду: category=$category, subcategory=$subcategory, sub=$subSubcategory',
    );
    print('📡 user_id в запросе: ${requestData['user_id']}');

    late final Response response;
    try {
      response = await _dio.post('/clothes/process', data: requestData);
    } on DioException catch (e) {
      print('❌ Ошибка addClothingItem статус: ${e.response?.statusCode}');
      print('❌ Тело ответа: ${e.response?.data}');
      rethrow;
    }

    print('✅ Одежда — ответ сервера: ${response.statusCode}');

    if (response.statusCode == 200) {
      // Берём обработанное фото без фона от сервера
      final processedBase64 = response.data['image_base64'] as String?;
      final imageToCache =
          processedBase64 != null
              ? (processedBase64.contains(',')
                  ? processedBase64.split(',').last
                  : processedBase64)
              : cleanBase64; // fallback на оригинал если сервер не вернул

      final model = PhotoModel(
        user_name: userName,
        image: imageToCache,
        category: category,
        subcategory: subcategory,
        sub_subcategory: subSubcategory,
      );
      await _wardrobeItemsBox.add(model);
    }
  }

  // ──────────────────────── TRYON ────────────────────────

  Future<String?> startTryon({
    required String personImageBase64,
    required String clothImageBase64,
    String clothType = 'upper',
  }) async {
    try {
      final personClean =
          personImageBase64.contains(',')
              ? personImageBase64.split(',').last
              : personImageBase64;
      final clothClean =
          clothImageBase64.contains(',')
              ? clothImageBase64.split(',').last
              : clothImageBase64;

      final response = await _dio.post(
        '/tryon/start',
        data: {
          'person_image': personClean,
          'cloth_image': clothClean,
          'cloth_type': clothType,
        },
      );

      if (response.statusCode == 202) {
        final taskId = response.data['task_id'] as String?;
        print('✅ Примерка запущена, task_id: $taskId');
        return taskId;
      }
    } catch (e) {
      print('❌ Ошибка startTryon: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getTryonStatus(String taskId) async {
    try {
      final response = await _dio.get('/tryon/status/$taskId');
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (e) {
      print('❌ Ошибка getTryonStatus: $e');
    }
    return null;
  }

  // ──────────────────────── CATALOG ────────────────────────

  @override
  Future<List<PhotoModel>> getCatalogItems() async => [];

  // ──────────────────────── DELETE ────────────────────────

  @override
  Future<void> deletePhoto(String id, String type) async {
    if (type == 'human') {
      final response = await _dio.delete('/human/delete/$id');
      if (response.statusCode == 200) {
        final entries = _humanPhotosBox.toMap();
        for (final entry in entries.entries) {
          if (entry.key.toString() == id ||
              entry.value.hashCode.toString() == id) {
            final base64 = entry.value;
            await _humanPhotosBox.delete(entry.key);
            await _deletedPhotosBox.add(
              DeletedPhotoModel.fromHumanPhoto(base64, 'user', id),
            );
            break;
          }
        }
      }
    } else if (type == 'wardrobe') {
      final response = await _dio.delete('/clothes/wardrobe/delete/$id');
      if (response.statusCode == 200) {
        final entries = _wardrobeItemsBox.toMap();
        for (final entry in entries.entries) {
          if (entry.value.hashCode.toString() == id) {
            final photo = entry.value;
            await _wardrobeItemsBox.delete(entry.key);
            await _deletedPhotosBox.add(
              DeletedPhotoModel.fromWardrobeItem(photo, id),
            );
            break;
          }
        }
      }
    }
  }

  // ──────────────────────── DELETED PHOTOS ────────────────────────

  Future<List<DeletedPhotoModel>> getDeletedPhotos() async {
    return _deletedPhotosBox.values.toList();
  }

  Future<void> permanentlyDeletePhoto(String imageBase64) async {
    final index = _deletedPhotosBox.values.toList().indexWhere(
      (photo) => photo.imageBase64 == imageBase64,
    );
    if (index != -1) {
      await _deletedPhotosBox.deleteAt(index);
    }
  }

  // ──────────────────────── MISC ────────────────────────

  @override
  Future<void> clearData() async {
    await _humanPhotosBox.clear();
    await _wardrobeItemsBox.clear();
    await _deletedPhotosBox.clear();
  }

  Future<bool> hasUpdates() async => false;
}
