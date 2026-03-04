import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:endimata/common/photo_upload/presentation/pages/clothes_category_selection_page.dart';
import 'package:endimata/common/photo_upload/presentation/pages/human_photo_preview_page.dart';
import '../../../../core/resources/dialog_state.dart';
import '../bloc/photo_upload_bloc.dart';
import '../bloc/photo_upload_event.dart';
import '../bloc/photo_upload_state.dart';

class CameraPage extends StatefulWidget {
  final bool isClothesUpload;
  const CameraPage({super.key, required this.isClothesUpload});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isPermissionGranted = false;
  bool _isPermissionChecked = false;
  bool _isTakingPhoto = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      DialogState.setActiveDialog(ActiveDialog.camera);
      context.read<PhotoUploadBloc>().add(ResetPhotoUploadEvent());
      context.read<PhotoUploadBloc>().add(
        SetUploadTypeEvent(widget.isClothesUpload),
      );
      await _checkAndRequestPermissions();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed && _isPermissionGranted) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  Future<void> _disposeCamera() async {
    await _cameraController?.dispose();
    _cameraController = null;
  }

  Future<void> _checkAndRequestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final photosStatus = await Permission.photos.request();

    final granted = cameraStatus.isGranted;

    if (!granted) {
      if (cameraStatus.isPermanentlyDenied) {
        _showSettingsDialog();
      }
    }

    setState(() {
      _isPermissionGranted = granted;
      _isPermissionChecked = true;
    });

    if (granted) {
      await _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final backCamera = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint('Ошибка инициализации камеры: $e');
    }
  }

  Future<void> _takePhoto() async {
    if (_isTakingPhoto ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() => _isTakingPhoto = true);

    try {
      final XFile photo = await _cameraController!.takePicture();
      if (!mounted) return;
      context.read<PhotoUploadBloc>().add(
        TakePhotoFromCameraWithFileEvent(photo.path),
      );
    } catch (e) {
      debugPrint('Ошибка съёмки: $e');
    } finally {
      if (mounted) setState(() => _isTakingPhoto = false);
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Нужны разрешения'),
            content: const Text(
              'Для съёмки фото необходим доступ к камере.\n\n'
              'Пожалуйста, разрешите в настройках приложения.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.pop(context);
                },
                child: const Text('Настройки'),
              ),
            ],
          ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isPermissionGranted) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              'Нет доступа к камере',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _checkAndRequestPermissions,
              child: const Text(
                'Разрешить доступ',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final previewAspect = _cameraController!.value.aspectRatio;
        return ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxWidth / previewAspect,
              child: CameraPreview(_cameraController!),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: BlocListener<PhotoUploadBloc, PhotoUploadState>(
        listener: (context, state) {
          if (state is PhotoUploadAwaitingCategoryState) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ClothesCategorySelectionPage(
                      imagePath: state.imagePath,
                    ),
              ),
            );
          } else if (state is PhotoUploadPreviewState) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return HumanPhotoPreviewPage(imagePath: state.imagePath);
              },
            );
          } else if (state is PhotoUploadResetState) {
            DialogState.setActiveDialog(ActiveDialog.none);
            Navigator.of(context).pop();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Живое превью камеры ──────────────────────────────────────
            _buildCameraPreview(),

            // ── Кнопка «Назад» ──────────────────────────────────────────
            Positioned(
              top: 40,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  context.read<PhotoUploadBloc>().add(CancelPhotoUploadEvent());
                },
                child: SvgPicture.asset(
                  'assets/icons/arrow_back_circled.svg',
                  width: 32,
                  height: 32,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            // ── Кнопка спуска затвора ────────────────────────────────────
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap:
                      _isPermissionChecked && _isCameraInitialized
                          ? _takePhoto
                          : null,
                  child:
                      _isTakingPhoto
                          ? const SizedBox(
                            width: 72,
                            height: 72,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                          : SvgPicture.asset(
                            'assets/icons/camera_circle.svg',
                            width: 72,
                            height: 72,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                ),
              ),
            ),

            // ── Кнопка «Галерея» ────────────────────────────────────────
            Positioned(
              bottom: 60,
              right: 40,
              child: GestureDetector(
                onTap: () async {
                  final status = await Permission.photos.request();
                  if (status.isGranted) {
                    if (mounted) {
                      context.read<PhotoUploadBloc>().add(
                        ChoosePhotoFromGalleryEvent(),
                      );
                    }
                  } else if (status.isPermanentlyDenied) {
                    _showSettingsDialog();
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.folder_outlined,
                      color: Colors.white,
                      size: 50,
                    ),
                    Text(
                      'Галерея',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontFamily: 'SFPro-Light',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
