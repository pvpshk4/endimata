import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:endimata/config/theme/app_colors.dart';

class PhotoToggleButton extends StatefulWidget {
  final bool isPhotoListVisible;
  final VoidCallback onTap;

  const PhotoToggleButton({
    super.key,
    required this.isPhotoListVisible,
    required this.onTap,
  });

  @override
  State<PhotoToggleButton> createState() => _PhotoToggleButtonState();
}

class _PhotoToggleButtonState extends State<PhotoToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    if (widget.isPhotoListVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(PhotoToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPhotoListVisible != oldWidget.isPhotoListVisible) {
      if (widget.isPhotoListVisible) {
        if (_controller.status == AnimationStatus.dismissed ||
            _controller.status == AnimationStatus.reverse) {
          _controller.forward();
        }
      } else {
        if (_controller.status == AnimationStatus.completed ||
            _controller.status == AnimationStatus.forward) {
          _controller.reverse();
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 30,
      left: 16,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: _animation.value * 1.5,
                  colors: [AppColors.primaryColor, Colors.white],
                  stops: const [0.0, 1.0],
                ),
              ),
              child: Center(
                child:
                    widget.isPhotoListVisible
                        ? SvgPicture.asset(
                          'assets/icons/human_photo_button_white.svg',
                          width: 34,
                          height: 34,
                        )
                        : SvgPicture.asset(
                          'assets/icons/human_photo_button_black.svg',
                          width: 34,
                          height: 34,
                        ),
              ),
            );
          },
        ),
      ),
    );
  }
}
