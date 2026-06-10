import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/resources/dialog_state.dart';
import '../../photo_upload/presentation/pages/camera_page.dart';
import '../widgets/custom_bottom_navigation_bar.dart';

class MainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final bool showCentralButton;
  final bool showBottomNavBar;

  const MainLayout({
    super.key,
    required this.navigationShell,
    required this.showCentralButton,
    required this.showBottomNavBar,
  });

  void _onItemTapped(BuildContext context, int index) {
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ActiveDialog>(
      valueListenable: DialogState.activeDialog,
      builder: (context, activeDialog, child) {
        final shouldShowBottomNavBar =
            showBottomNavBar &&
            (activeDialog == ActiveDialog.none ||
                activeDialog == ActiveDialog.clothesCategorySelection);
        final shouldShowCentralButton =
            showCentralButton &&
            activeDialog != ActiveDialog.clothesCategorySelection;

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: navigationShell,
          bottomNavigationBar:
              shouldShowBottomNavBar
                  ? CustomBottomNavigationBar(
                    currentIndex: navigationShell.currentIndex,
                    onTap: (index) => _onItemTapped(context, index),
                    activeTextColor: AppColors.primaryColor,
                    showCentralButton: shouldShowCentralButton,
                    // Кнопка "Одежда" — старая логика
                    onCentralButtonTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return CameraPage(isClothesUpload: true);
                        },
                      );
                    },
                    // Кнопка "Фото человека" — новая
                    onAddHumanPhotoTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return CameraPage(isClothesUpload: false);
                        },
                      );
                    },
                  )
                  : null,
        );
      },
    );
  }
}
