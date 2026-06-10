import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:endimata/common/AppData/presentation/bloc/app_data_bloc.dart';

class PhotoListWidget extends StatefulWidget {
  final VoidCallback onClose;
  final Function(String?) onPhotoSelected;

  const PhotoListWidget({
    super.key,
    required this.onClose,
    required this.onPhotoSelected,
  });

  @override
  State<PhotoListWidget> createState() => _PhotoListWidgetState();
}

class _PhotoListWidgetState extends State<PhotoListWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.7, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    _scaleAnimation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void closeWidgetWithAnimation() {
    _controller.reverse().then((_) => widget.onClose());
  }

  @override
  Widget build(BuildContext context) {
    final photos = context.read<AppDataBloc>().state.humanPhotos;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Полупрозрачный нейтральный фон для обеих тем:
    // тёмная — белый туман, светлая — серая дымка
    final containerColor =
        isDark
            ? Colors.white.withOpacity(0.13)
            : Colors.black.withOpacity(0.07);

    final borderColor =
        isDark
            ? Colors.white.withOpacity(0.18)
            : Colors.black.withOpacity(0.10);

    final emptyTextColor = isDark ? Colors.white54 : Colors.black38;
    final errorIconColor = isDark ? Colors.white38 : Colors.black26;

    return Positioned(
      top: 10,
      left: 65,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(position: _slideAnimation, child: child),
            ),
          );
        },
        child: Container(
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 0.5),
          ),
          child:
              photos.isEmpty
                  ? SizedBox(
                    width: MediaQuery.of(context).size.width - (16 + 42 + 24),
                    child: Center(
                      child: Text(
                        'Нет фото',
                        style: TextStyle(
                          color: emptyTextColor,
                          fontSize: 14,
                          fontFamily: 'SFPro-Light',
                        ),
                      ),
                    ),
                  )
                  : SizedBox(
                    height: 100,
                    width: MediaQuery.of(context).size.width - (16 + 42 + 24),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                        final photo = photos[index];
                        return _buildPhotoItem(photo, errorIconColor);
                      },
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildPhotoItem(String base64Photo, Color errorIconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () {
          widget.onPhotoSelected(base64Photo);
          closeWidgetWithAnimation();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            base64Decode(
              base64Photo.contains(',')
                  ? base64Photo.split(',').last
                  : base64Photo,
            ),
            width: 70,
            height: 90,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 70,
                height: 90,
                color: Colors.transparent,
                child: Icon(Icons.error, color: errorIconColor),
              );
            },
          ),
        ),
      ),
    );
  }
}
