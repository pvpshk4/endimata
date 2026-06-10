import 'package:dio/dio.dart';
import 'package:endimata/common/AppData/data/data_sources/remote/flask_app_data_service.dart';
import 'package:endimata/common/theme/theme_bloc.dart';
import 'package:endimata/common/utils/debug_logger.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:endimata/common/AppData/data/data_sources/remote/app_data_api_service.dart';
import 'package:endimata/common/AppData/data/data_sources/remote/mock_app_data_api_service.dart';
import 'package:endimata/common/AppData/data/models/deleted_photo_model.dart';
import 'package:endimata/common/AppData/data/models/photo_model.dart';
import 'package:endimata/common/AppData/data/models/photo_model_adapter.dart';
import 'package:endimata/common/AppData/domain/repositories/app_data_repository.dart';
import 'package:endimata/common/AppData/presentation/bloc/app_data_bloc.dart';
import 'package:endimata/common/photo_upload/data/data_sources/remote/photo_remote_data_source.dart';
import 'package:endimata/common/photo_upload/presentation/bloc/photo_upload_bloc.dart';
import 'package:endimata/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:endimata/features/auth/domain/repositories/auth_repository.dart';
import 'package:endimata/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:endimata/features/auth/presentation/bloc/auth_state.dart';
import 'package:endimata/features/home/data/repositories/home_repository_impl.dart';
import 'package:endimata/features/home/domain/repositories/home_repository.dart';
import 'package:endimata/features/home/presentation/bloc/home_bloc.dart';
import 'package:endimata/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:endimata/features/wardrobe/data/data_sources/remote/wardrobe_remote_data_source.dart';
import 'package:endimata/features/wardrobe/data/repositories/wardrobe_repository_impl.dart';
import 'package:endimata/features/wardrobe/domain/repositories/wardrobe_repository.dart';
import 'package:endimata/features/wardrobe/presentation/bloc/wardrobe_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await _initExternal();
  await _initHive();
  _initServices();
  _initRepositories();
  _initBlocs();
  _initAuthListener();
}

// ──────────────────────────────────────────────────────────────
// EXTERNAL
// ──────────────────────────────────────────────────────────────

Future<void> _initExternal() async {
  sl.registerSingleton<http.Client>(http.Client());
  sl.registerSingleton<Dio>(Dio());

  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
}

// ──────────────────────────────────────────────────────────────
// HIVE
// ──────────────────────────────────────────────────────────────

Future<void> _initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(PhotoModelAdapter());
  Hive.registerAdapter(DeletedPhotoModelAdapter());

  final humanPhotosBox = await Hive.openBox<String>('humanPhotos');
  final catalogItemsBox = await Hive.openBox<PhotoModel>('catalogItems');
  final wardrobeItemsBox = await Hive.openBox<PhotoModel>('wardrobeItems');
  final deletedPhotosBox = await Hive.openBox<DeletedPhotoModel>(
    'deletedPhotos',
  );

  sl.registerSingleton<Box<String>>(humanPhotosBox);
  sl.registerSingleton<Box<PhotoModel>>(
    catalogItemsBox,
    instanceName: 'catalogItemsBox',
  );
  sl.registerSingleton<Box<PhotoModel>>(
    wardrobeItemsBox,
    instanceName: 'wardrobeItemsBox',
  );
  sl.registerSingleton<Box<DeletedPhotoModel>>(
    deletedPhotosBox,
    instanceName: 'deletedPhotosBox',
  );
}

// ──────────────────────────────────────────────────────────────
// SERVICES
// ──────────────────────────────────────────────────────────────

void _initServices() {
  final flaskService = FlaskAppDataService(
    humanPhotosBox: sl<Box<String>>(),
    wardrobeItemsBox: sl<Box<PhotoModel>>(instanceName: 'wardrobeItemsBox'),
    deletedPhotosBox: sl<Box<DeletedPhotoModel>>(
      instanceName: 'deletedPhotosBox',
    ),
  );

  sl.registerSingleton<AppDataApiService>(flaskService);
  sl.registerSingleton<FlaskAppDataService>(flaskService);

  sl.registerSingleton<PhotoRemoteDataSource>(
    PhotoRemoteDataSourceImpl(apiService: flaskService),
  );
  sl.registerSingleton<WardrobeRemoteDataSource>(
    WardrobeRemoteDataSourceImpl(flaskService),
  );
}

// ──────────────────────────────────────────────────────────────
// REPOSITORIES
// ──────────────────────────────────────────────────────────────

void _initRepositories() {
  sl.registerSingleton<AppDataRepository>(
    AppDataRepository(sl<FlaskAppDataService>()),
  );
  sl.registerSingleton<WardrobeRepository>(
    WardrobeRepositoryImpl(remoteDataSource: sl<WardrobeRemoteDataSource>()),
  );
  sl.registerSingleton<HomeRepository>(HomeRepositoryImpl());
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());
}

// ──────────────────────────────────────────────────────────────
// BLOCS
// ──────────────────────────────────────────────────────────────

void _initBlocs() {
  sl.registerSingleton<ThemeBloc>(ThemeBloc());
  sl.registerSingleton<AppDataBloc>(
    AppDataBloc(sl<AppDataRepository>(), sl<SharedPreferences>()),
  );
  sl.registerSingleton<PhotoUploadBloc>(PhotoUploadBloc(sl<AppDataBloc>()));
  sl.registerSingleton<WardrobeBloc>(
    WardrobeBloc(remoteDataSource: sl<WardrobeRemoteDataSource>()),
  );
  sl.registerSingleton<HomeBloc>(HomeBloc(sl<AppDataBloc>()));
  sl.registerSingleton<ProfileBloc>(ProfileBloc(sl()));
  sl.registerSingleton<AuthBloc>(AuthBloc(sl()));
}

// ──────────────────────────────────────────────────────────────
// AUTH LISTENER
// ──────────────────────────────────────────────────────────────

void _initAuthListener() {
  sl<AuthBloc>().stream.listen((authState) async {
    if (authState is AuthAuthenticatedState) {
      await _switchToFlask(authState.user.id);
    }
  });
}

Future<void> _switchToFlask(String firebaseUserId) async {
  print('🔄 Переключаемся на Flask, Firebase UID: $firebaseUserId');

  final flaskService = FlaskAppDataService(
    humanPhotosBox: sl<Box<String>>(),
    wardrobeItemsBox: sl<Box<PhotoModel>>(instanceName: 'wardrobeItemsBox'),
    deletedPhotosBox: sl<Box<DeletedPhotoModel>>(
      instanceName: 'deletedPhotosBox',
    ),
  );

  // Получаем JWT токен
  final token = await flaskService.refreshJwtTokenPublic();
  print('🎟️ JWT токен: ${token != null ? "ПОЛУЧЕН" : "НЕ ПОЛУЧЕН"}');

  // Создаём новый репозиторий с Flask сервисом
  final newRepository = AppDataRepository(flaskService);

  // Напрямую обновляем репозиторий в AppDataBloc — без пересоздания блока
  sl<AppDataBloc>().updateRepository(newRepository);
}

void _switchToMock() {
  final mockService = _createMockService();
  final newRepository = AppDataRepository(mockService);
  sl<AppDataBloc>().updateRepository(newRepository);
}

// ──────────────────────────────────────────────────────────────
// HELPERS
// ──────────────────────────────────────────────────────────────

MockAppDataApiService _createMockService() => MockAppDataApiService(
  sl<Box<String>>(),
  sl<Box<PhotoModel>>(instanceName: 'catalogItemsBox'),
  sl<Box<PhotoModel>>(instanceName: 'wardrobeItemsBox'),
  sl<Box<DeletedPhotoModel>>(instanceName: 'deletedPhotosBox'),
);
