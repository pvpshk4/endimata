import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:endimata/common/photo_upload/domain/entities/photo_entity.dart';
import 'package:endimata/common/AppData/presentation/bloc/app_data_bloc.dart';
import 'package:endimata/common/AppData/presentation/bloc/app_data_event.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'photo_upload_event.dart';
import 'photo_upload_state.dart';
import 'dart:convert';

class PhotoUploadBloc extends Bloc<PhotoUploadEvent, PhotoUploadState> {
  final AppDataBloc _appDataBloc;
  final ImagePicker _picker = ImagePicker();
  bool _isClothesUpload = false;
  File? _selectedImage;
  String? _category;
  String? _subcategory;
  String? _subSubcategory;

  PhotoUploadBloc(this._appDataBloc) : super(PhotoUploadInitialState()) {
    on<SetUploadTypeEvent>(_onSetUploadType);
    on<TakePhotoFromCameraEvent>(_onTakePhotoFromCamera);
    on<TakePhotoFromCameraWithFileEvent>(_onTakePhotoFromCameraWithFile);
    on<ChoosePhotoFromGalleryEvent>(_onChoosePhotoFromGallery);
    on<CancelPhotoUploadEvent>(_onCancelPhotoUpload);
    on<SelectCategoryEvent>(_onSelectCategory);
    on<SavePhotoEvent>(_onSavePhoto);
    on<ResetPhotoUploadEvent>(_onResetPhotoUpload);
  }

  Future<Uint8List> _compressImage(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;

    img.Image resized = image;
    if (image.width > 1080 || image.height > 1080) {
      resized = img.copyResize(
        image,
        width: image.width > image.height ? 1080 : -1,
        height: image.height > image.width ? 1080 : -1,
      );
    }

    return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
  }

  /// Получает реальный username пользователя.
  /// Приоритет: flask_user_id → Firebase UID → 'guest'
  Future<String> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final flaskUserId = prefs.getString('flask_user_id');
    if (flaskUserId != null && flaskUserId.isNotEmpty) {
      return 'user_$flaskUserId';
    }
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      return firebaseUser.uid;
    }
    return 'guest';
  }

  void _onSetUploadType(
    SetUploadTypeEvent event,
    Emitter<PhotoUploadState> emit,
  ) {
    _isClothesUpload = event.isClothesUpload;
  }

  Future<void> _onTakePhotoFromCamera(
    TakePhotoFromCameraEvent event,
    Emitter<PhotoUploadState> emit,
  ) async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        emit(const PhotoUploadFailureState('Нет доступа к камере'));
        return;
      }
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        if (_isClothesUpload) {
          emit(PhotoUploadAwaitingCategoryState(pickedFile.path));
        } else {
          emit(PhotoUploadPreviewState(pickedFile.path));
        }
      }
    } catch (e) {
      emit(PhotoUploadFailureState('Ошибка при съёмке фото: $e'));
    }
  }

  Future<void> _onTakePhotoFromCameraWithFile(
    TakePhotoFromCameraWithFileEvent event,
    Emitter<PhotoUploadState> emit,
  ) async {
    _selectedImage = File(event.filePath);
    if (_isClothesUpload) {
      emit(PhotoUploadAwaitingCategoryState(event.filePath));
    } else {
      emit(PhotoUploadPreviewState(event.filePath));
    }
  }

  Future<void> _onChoosePhotoFromGallery(
    ChoosePhotoFromGalleryEvent event,
    Emitter<PhotoUploadState> emit,
  ) async {
    try {
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        emit(const PhotoUploadFailureState('Нет доступа к галерее'));
        return;
      }
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        if (_isClothesUpload) {
          emit(PhotoUploadAwaitingCategoryState(pickedFile.path));
        } else {
          emit(PhotoUploadPreviewState(pickedFile.path));
        }
      }
    } catch (e) {
      emit(PhotoUploadFailureState('Ошибка при выборе фото: $e'));
    }
  }

  Future<void> _onCancelPhotoUpload(
    CancelPhotoUploadEvent event,
    Emitter<PhotoUploadState> emit,
  ) async {
    _selectedImage = null;
    _category = null;
    _subcategory = null;
    _subSubcategory = null;
    _isClothesUpload = false;
    emit(PhotoUploadResetState());
  }

  Future<void> _onSelectCategory(
    SelectCategoryEvent event,
    Emitter<PhotoUploadState> emit,
  ) async {
    _category = event.category;
    _subcategory = event.subcategory;
    _subSubcategory = event.subSubcategory;
  }

  Future<void> _onSavePhoto(
    SavePhotoEvent event,
    Emitter<PhotoUploadState> emit,
  ) async {
    if (_selectedImage == null) {
      emit(const PhotoUploadFailureState('Нет выбранного изображения'));
      return;
    }

    emit(PhotoUploadLoadingState());
    try {
      final username = await _getUsername();
      final compressedBytes = await _compressImage(_selectedImage!);
      final base64Image = base64Encode(compressedBytes);

      if (_isClothesUpload) {
        if (_category == null ||
            _subcategory == null ||
            _subSubcategory == null) {
          emit(const PhotoUploadFailureState('Категории не выбраны'));
          return;
        }
        final photoEntity = PhotoEntity(
          user_name: username,
          image: base64Image,
          category: _category!,
          subcategory: _subcategory!,
          sub_subcategory: _subSubcategory!,
        );
        _appDataBloc.add(
          AddWardrobeItemEvent(
            fileBase64: photoEntity.image,
            userName: username,
            category: photoEntity.category,
            subcategory: photoEntity.subcategory,
            subSubcategory: photoEntity.sub_subcategory,
          ),
        );
        emit(PhotoUploadSuccessState(photoEntity));
      } else {
        final photoEntity = PhotoEntity(
          user_name: username,
          image: base64Image,
          category: 'full',
          subcategory: '',
          sub_subcategory: '',
        );
        _appDataBloc.add(
          AddHumanPhotoEvent(
            photoBase64: 'data:image/png;base64,${photoEntity.image}',
            userName: username,
          ),
        );
        emit(PhotoUploadSuccessState(photoEntity));
      }
    } catch (e) {
      emit(PhotoUploadFailureState('Ошибка при загрузке фото: $e'));
    }
  }

  Future<void> _onResetPhotoUpload(
    ResetPhotoUploadEvent event,
    Emitter<PhotoUploadState> emit,
  ) async {
    _selectedImage = null;
    _category = null;
    _subcategory = null;
    _subSubcategory = null;
    _isClothesUpload = false;
    emit(PhotoUploadInitialState());
  }
}
