import 'package:dio/dio.dart';
import 'package:endimata/common/theme/theme_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:endimata/common/AppData/data/data_sources/remote/app_data_api_service.dart';
import 'package:endimata/common/AppData/data/data_sources/remote/mock_app_data_api_service.dart';
import 'package:endimata/common/AppData/data/data_sources/remote/supabase_app_data_service.dart';
import 'package:endimata/common/AppData/data/models/deleted_photo_model.dart';
import 'package:endimata/common/AppData/data/models/photo_model.dart';
import 'package:endimata/common/AppData/data/models/photo_model_adapter.dart';
import 'package:endimata/common/AppData/domain/repositories/app_data_repository.dart';
import 'package:endimata/common/AppData/presentation/bloc/app_data_bloc.dart';
import 'package:endimata/common/AppData/presentation/bloc/app_data_event.dart';
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
  // По умолчанию — Mock (Hive) для гостей
  sl.registerSingleton<AppDataApiService>(_createMockService());

  sl.registerSingleton<PhotoRemoteDataSource>(
    PhotoRemoteDataSourceImpl(apiService: sl<AppDataApiService>()),
  );
  sl.registerSingleton<WardrobeRemoteDataSource>(
    WardrobeRemoteDataSourceImpl(sl<AppDataApiService>()),
  );
}

// ──────────────────────────────────────────────────────────────
// REPOSITORIES
// ──────────────────────────────────────────────────────────────

void _initRepositories() {
  sl.registerSingleton<AppDataRepository>(
    AppDataRepository(sl<AppDataApiService>()),
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
// AUTH LISTENER — переключение сервисов при входе/выходе
// ──────────────────────────────────────────────────────────────

void _initAuthListener() {
  sl<AuthBloc>().stream.listen((authState) async {
    if (authState is AuthAuthenticatedState) {
      await _switchToSupabase(authState.user.id);
    } else if (authState is AuthUnauthenticatedState) {
      _switchToMock();
    }
  });
}

Future<void> _switchToSupabase(String userId) async {
  final supabaseService = SupabaseAppDataService(
    userId,
    humanPhotosBox: sl<Box<String>>(),
    wardrobeItemsBox: sl<Box<PhotoModel>>(instanceName: 'wardrobeItemsBox'),
    deletedPhotosBox: sl<Box<DeletedPhotoModel>>(
      instanceName: 'deletedPhotosBox',
    ),
  );

  await supabaseService.syncFromSupabase();

  _reregisterDataLayer(supabaseService);
}

void _switchToMock() {
  _reregisterDataLayer(_createMockService());
}

void _reregisterDataLayer(AppDataApiService service) {
  sl.unregister<WardrobeRepository>();
  sl.unregister<AppDataRepository>();
  sl.unregister<WardrobeRemoteDataSource>();
  sl.unregister<PhotoRemoteDataSource>();

  sl.registerSingleton<PhotoRemoteDataSource>(
    PhotoRemoteDataSourceImpl(apiService: service),
  );
  sl.registerSingleton<WardrobeRemoteDataSource>(
    WardrobeRemoteDataSourceImpl(service),
  );
  sl.registerSingleton<AppDataRepository>(AppDataRepository(service));
  sl.registerSingleton<WardrobeRepository>(
    WardrobeRepositoryImpl(remoteDataSource: sl<WardrobeRemoteDataSource>()),
  );

  sl<AppDataBloc>().add(const LoadAppDataEvent());
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
