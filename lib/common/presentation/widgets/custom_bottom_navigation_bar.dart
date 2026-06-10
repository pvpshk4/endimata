import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../config/theme/app_colors.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Color? backgroundColor;
  final Color activeTextColor;
  final bool showCentralButton;
  final VoidCallback onCentralButtonTap;
  final VoidCallback? onAddHumanPhotoTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.activeTextColor = AppColors.primaryColor,
    required this.showCentralButton,
    required this.onCentralButtonTap,
    this.onAddHumanPhotoTap,
  });

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  OverlayEntry? _overlayEntry;

  late AnimationController _controller;
  late Animation<double> _rotateAnimation;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleExpand() {
    _isExpanded ? _closeMenu() : _openMenu();
  }

  void _openMenu() {
    setState(() => _isExpanded = true);
    _controller.forward(from: 0.0);
    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeMenu() {
    setState(() => _isExpanded = false);
    _controller.reverse().then((_) => _removeOverlay());
  }

  void _closeAndRun(VoidCallback action) {
    setState(() => _isExpanded = false);
    _controller.reverse().then((_) {
      _removeOverlay();
      action();
    });
  }

  OverlayEntry _buildOverlayEntry() {
    return OverlayEntry(
      builder: (_) {
        final mq = MediaQuery.of(context);
        final centerBtnBottom = mq.padding.bottom + (73.0 / 2) + 3.0;
        const horizontalPadding = 16.0;
        const gap = 12.0;
        const minBtnWidth = 120.0;
        final screenWidth = mq.size.width;
        final availableWidth = screenWidth - horizontalPadding * 2;
        final useRow = availableWidth >= minBtnWidth * 2 + gap;
        final btnWidth = useRow ? (availableWidth - gap) / 2 : availableWidth;
        final btnHeight = 52.0;

        final targetBottom = mq.padding.bottom + 73.0 + 16.0;

        return Material(
          type: MaterialType.transparency,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              final progress = _expandAnimation.value;
              final fade = _fadeAnimation.value.clamp(0.0, 1.0);

              final currentBottom = lerpDouble(
                centerBtnBottom - btnHeight / 2,
                targetBottom,
                progress,
              );

              final centerX = screenWidth / 2;

              final leftBtnFinalLeft = horizontalPadding;
              final rightBtnFinalLeft =
                  useRow
                      ? horizontalPadding + btnWidth + gap
                      : horizontalPadding;

              final leftBtnStartLeft = centerX - btnWidth / 2;
              final rightBtnStartLeft = centerX - btnWidth / 2;

              final leftBtnLeft = lerpDouble(
                leftBtnStartLeft,
                leftBtnFinalLeft,
                progress,
              );
              final rightBtnLeft = lerpDouble(
                rightBtnStartLeft,
                rightBtnFinalLeft,
                progress,
              );

              final topBtnFinalBottom =
                  useRow ? targetBottom : targetBottom + btnHeight + gap;
              final bottomBtnFinalBottom = targetBottom;

              final topBtnBottom =
                  useRow
                      ? currentBottom!
                      : lerpDouble(
                        centerBtnBottom - btnHeight / 2,
                        topBtnFinalBottom,
                        progress,
                      )!;
              final bottomBtnCurrentBottom =
                  useRow
                      ? currentBottom!
                      : lerpDouble(
                        centerBtnBottom - btnHeight / 2,
                        bottomBtnFinalBottom,
                        progress,
                      )!;

              return Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _closeMenu,
                      child: const SizedBox.expand(),
                    ),
                  ),

                  Positioned(
                    bottom: topBtnBottom,
                    left: leftBtnLeft,
                    child: Opacity(
                      opacity: fade,
                      child: _buildBtn(
                        label: 'Одежда',
                        icon: Icons.checkroom_outlined,
                        onTap: () => _closeAndRun(widget.onCentralButtonTap),
                        width: btnWidth,
                        height: btnHeight,
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: bottomBtnCurrentBottom,
                    left: rightBtnLeft,
                    child: Opacity(
                      opacity: fade,
                      child: _buildBtn(
                        label: 'Фото',
                        icon: Icons.person_outline,
                        onTap: () {
                          if (widget.onAddHumanPhotoTap != null) {
                            _closeAndRun(widget.onAddHumanPhotoTap!);
                          }
                        },
                        width: btnWidth,
                        height: btnHeight,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBtn({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required double width,
    required double height,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final shadowColor = isDark ? Colors.black54 : Colors.black26;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'SFPro-Medium',
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = widget.backgroundColor ?? theme.scaffoldBackgroundColor;
    final inactiveColor =
        theme.brightness == Brightness.dark
            ? Colors.white60
            : AppColors.secondaryColor;

    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        color: bgColor,
        height: 73,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              'home_icon.svg',
              'Главная',
              0,
              inactiveColor,
              size: 24,
            ),
            _buildNavItem(
              context,
              'catalog_icon.svg',
              'Каталог',
              1,
              inactiveColor,
              size: 20,
            ),
            widget.showCentralButton
                ? _buildCentralButton()
                : const SizedBox(width: 60),
            _buildNavItem(
              context,
              'wardrobe_icon.svg',
              'Гардероб',
              2,
              inactiveColor,
              size: 24,
            ),
            _buildNavItem(
              context,
              'profile_icon.svg',
              'Профиль',
              3,
              inactiveColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCentralButton() {
    return Transform.translate(
      offset: const Offset(0, -3),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleExpand,
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
          ),
          child: AnimatedBuilder(
            animation: _rotateAnimation,
            builder: (_, __) {
              return Transform.rotate(
                angle: _rotateAnimation.value * 6 * 3.14159,
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String icon,
    String label,
    int index,
    Color inactiveColor, {
    double size = 22,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_isExpanded) _closeMenu();
        widget.onTap(index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/$icon',
              width: size,
              height: size,
              colorFilter: ColorFilter.mode(
                index == widget.currentIndex
                    ? AppColors.primaryColor
                    : inactiveColor,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'SFPro-Medium',
                color:
                    index == widget.currentIndex
                        ? widget.activeTextColor
                        : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double? lerpDouble(double a, double b, double t) {
  return a + (b - a) * t;
}
