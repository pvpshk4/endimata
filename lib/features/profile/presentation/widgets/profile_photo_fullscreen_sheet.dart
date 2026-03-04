import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:endimata/config/theme/app_colors.dart';

class ProfilePhotoFullscreenSheet extends StatefulWidget {
  final String photo;
  final VoidCallback onSet;
  final VoidCallback onDelete;

  const ProfilePhotoFullscreenSheet({
    super.key,
    required this.photo,
    required this.onSet,
    required this.onDelete,
  });

  @override
  State<ProfilePhotoFullscreenSheet> createState() =>
      _ProfilePhotoFullscreenSheetState();
}

class _ProfilePhotoFullscreenSheetState
    extends State<ProfilePhotoFullscreenSheet> {
  late final Uint8List imageBytes;

  @override
  void initState() {
    super.initState();
    final base64String =
        widget.photo.contains(',')
            ? widget.photo.split(',').last
            : widget.photo;
    imageBytes = base64Decode(base64String);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final offset = screenHeight * 0.01;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sheetBg = theme.scaffoldBackgroundColor;
    final borderColor = isDark ? Colors.white24 : Colors.black;
    final iconColor = isDark ? Colors.white70 : Colors.black;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20.0),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                Transform.translate(
                  offset: Offset(0, -offset - 8),
                  child: Container(
                    width: 230,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : AppColors.greyColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: offset * 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.memory(
                      imageBytes,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: screenHeight * 0.5,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color:
                                isDark
                                    ? const Color(0xFF2C2C2C)
                                    : AppColors.greyColor,
                            height: screenHeight * 0.5,
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 50,
                            ),
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: borderColor, width: 0.5),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: sheetBg,
                        child: InkWell(
                          onTap: widget.onDelete,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              'assets/icons/trash_can_icon.svg',
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                iconColor,
                                BlendMode.srcIn,
                              ),
                              placeholderBuilder:
                                  (context) => Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.onSet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                          ),
                          child: const Text(
                            'Установить',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontFamily: 'SFPro-Bold',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
