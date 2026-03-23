import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/resources/dialog_state.dart';
import '../bloc/photo_upload_bloc.dart';
import '../bloc/photo_upload_event.dart';
import '../bloc/photo_upload_state.dart';
import '../widgets/custom_check_box.dart';

class HumanPhotoPreviewPage extends StatefulWidget {
  final String imagePath;

  const HumanPhotoPreviewPage({super.key, required this.imagePath});

  @override
  State<HumanPhotoPreviewPage> createState() => _HumanPhotoPreviewPageState();
}

class _HumanPhotoPreviewPageState extends State<HumanPhotoPreviewPage> {
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DialogState.setActiveDialog(ActiveDialog.humanPhotoPreview);
    });
  }

  @override
  void dispose() {
    // Сбрасываем DialogState при закрытии
    DialogState.setActiveDialog(ActiveDialog.none);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          DialogState.setActiveDialog(ActiveDialog.none);
        }
      },
      child: Dialog(
        insetPadding: EdgeInsets.zero,
        child: Container(
          color: Colors.black,
          child: BlocConsumer<PhotoUploadBloc, PhotoUploadState>(
            listener: (context, state) {
              if (state is PhotoUploadSuccessState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  DialogState.setActiveDialog(ActiveDialog.none);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Фото успешно загружено')),
                );
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else if (state is PhotoUploadFailureState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  DialogState.setActiveDialog(ActiveDialog.none);
                });
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else if (state is PhotoUploadResetState) {
                Navigator.of(context).pop();
              }
            },
            builder: (context, state) {
              return Stack(
                children: [
                  Positioned.fill(
                    child:
                        state is PhotoUploadSuccessState
                            ? Image.memory(
                              base64Decode(state.photo.image),
                              fit: BoxFit.cover,
                            )
                            : Image.file(
                              File(widget.imagePath),
                              fit: BoxFit.cover,
                            ),
                  ),
                  // Кнопка назад
                  Positioned(
                    top: 40,
                    left: 16,
                    child: GestureDetector(
                      onTap: () {
                        context.read<PhotoUploadBloc>().add(
                          CancelPhotoUploadEvent(),
                        );
                      },
                      child: SvgPicture.asset(
                        'assets/icons/arrow_back_circled.svg',
                        width: 46,
                        height: 46,
                      ),
                    ),
                  ),
                  // Чекбокс подтверждения
                  Positioned(
                    top: 40,
                    right: 16,
                    child: CustomCheckBox(
                      value: _isChecked,
                      onChanged: (value) {
                        setState(() {
                          _isChecked = value ?? false;
                        });
                      },
                    ),
                  ),
                  // Кнопка загрузки
                  Positioned(
                    bottom: 32,
                    left: 0,
                    right: 0,
                    child: Center(
                      child:
                          state is PhotoUploadLoadingState
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                onPressed:
                                    _isChecked
                                        ? () => context
                                            .read<PhotoUploadBloc>()
                                            .add(SavePhotoEvent(context))
                                        : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: const Text(
                                  'Загрузить',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontFamily: 'SFPro-Medium',
                                  ),
                                ),
                              ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
