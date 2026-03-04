import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:endimata/common/presentation/dialogs/confirmation_dialog.dart';
import 'package:endimata/common/presentation/dialogs/restore_confirmation_dialog.dart';
import 'package:endimata/config/theme/app_colors.dart';
import 'package:endimata/features/profile/presentation/widgets/profile_photo_fullscreen_sheet.dart';
import '../../../../common/AppData/presentation/bloc/app_data_bloc.dart';
import '../../../../common/AppData/presentation/bloc/app_data_event.dart';
import '../../../../common/presentation/dialogs/permanent_delete_confirmation_dialog.dart';
import 'deleted_photo_fullscreen_sheet.dart';

// ignore: must_be_immutable
class PhotoGrid extends StatelessWidget {
  final List<String> photos;
  final bool isDeletedPhotos;
  final Set<String> selectedPhotos;
  final Function(String) onPhotoTapped;
  final Function(String) onPhotoLongPressed;
  final Function(String)? onDelete;
  final Function(String)? onRestore;
  final Function(String)? onSetPhoto;

  const PhotoGrid({
    super.key,
    required this.photos,
    this.isDeletedPhotos = false,
    required this.selectedPhotos,
    required this.onPhotoTapped,
    required this.onPhotoLongPressed,
    this.onDelete,
    this.onRestore,
    this.onSetPhoto,
  });

  void _showFullscreenSheet(BuildContext context, String photo) {
    if (isDeletedPhotos) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (sheetContext) => DeletedPhotoFullscreenSheet(
              photo: photo,
              onRestore: () {
                showDialog(
                  context: sheetContext,
                  builder:
                      (dialogContext) => RestoreConfirmationDialog(
                        onConfirm: () {
                          context.read<AppDataBloc>().add(
                            RestorePhotosEvent([photo]),
                          );
                          Navigator.pop(dialogContext);
                          Navigator.pop(sheetContext);
                        },
                        onCancel: () => Navigator.pop(dialogContext),
                      ),
                );
              },
              onDelete: () {
                showDialog(
                  context: sheetContext,
                  builder:
                      (dialogContext) => PermanentDeleteConfirmationDialog(
                        onConfirm: () {
                          context.read<AppDataBloc>().add(
                            PermanentlyDeletePhotosEvent([photo]),
                          );
                          Navigator.pop(dialogContext);
                          Navigator.pop(sheetContext);
                        },
                        onCancel: () => Navigator.pop(dialogContext),
                      ),
                );
              },
            ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (sheetContext) => ProfilePhotoFullscreenSheet(
              photo: photo,
              onSet: () {
                if (onSetPhoto != null) {
                  onSetPhoto!(photo);
                }
                Navigator.pop(sheetContext);
              },
              onDelete: () {
                showDialog(
                  context: sheetContext,
                  builder:
                      (dialogContext) => ConfirmationDialog(
                        onConfirm: () {
                          final state = sheetContext.read<AppDataBloc>().state;
                          if (state.humanPhotos.contains(photo)) {
                            sheetContext.read<AppDataBloc>().add(
                              DeletePhotosEvent([photo]),
                            );
                          }
                          Navigator.pop(dialogContext);
                          Navigator.pop(sheetContext);
                        },
                        onCancel: () => Navigator.pop(dialogContext),
                      ),
                );
              },
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.7,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        final base64String =
            photo.contains(',') ? photo.split(',').last : photo;
        final isSelected = selectedPhotos.contains(photo);

        return GestureDetector(
          onTap: () {
            if (selectedPhotos.isNotEmpty) {
              onPhotoTapped(photo);
            } else {
              _showFullscreenSheet(context, photo);
            }
          },
          onLongPress: () => onPhotoLongPressed(photo),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.memory(
                    base64Decode(base64String),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                ),
              ),
              if (selectedPhotos.isNotEmpty && !isSelected)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              if (selectedPhotos.isNotEmpty)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Transform.scale(
                    scale: 1.3,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        onPhotoTapped(photo);
                      },
                      activeColor: AppColors.primaryColor,
                      checkColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
