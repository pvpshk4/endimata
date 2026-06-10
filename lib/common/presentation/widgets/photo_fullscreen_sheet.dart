import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:endimata/config/theme/app_colors.dart';

class PhotoFullscreenSheet extends StatelessWidget {
  final String photo;
  final VoidCallback onSet;
  final VoidCallback onDelete;

  const PhotoFullscreenSheet({
    super.key,
    required this.photo,
    required this.onSet,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final base64String = photo.contains(',') ? photo.split(',').last : photo;
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder:
          (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Индикатор для смахивания
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Фотография
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.memory(
                        base64Decode(base64String),
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.5,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: Colors.grey[300],
                              height: MediaQuery.of(context).size.height * 0.5,
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
                  // Кнопки
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Кнопка "Удалить"
                        ElevatedButton(
                          onPressed: onDelete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: const EdgeInsets.all(12.0),
                            minimumSize: const Size(50, 50),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Кнопка "Установить"
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onSet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 15.0,
                              ),
                            ),
                            child: const Text(
                              'Установить',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'SFPro-Medium',
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
          ),
    );
  }
}
