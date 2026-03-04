import 'package:flutter/material.dart';
import 'package:endimata/config/theme/app_colors.dart';
import 'package:endimata/features/home/presentation/widgets/catalog_tab.dart';
import 'package:endimata/features/home/presentation/widgets/wardrobe_tab.dart';
import 'package:animations/animations.dart';

class PanelContentWidget extends StatelessWidget {
  final int selectedTabIndex;
  final Function(int) onTabSelected;
  final ScrollController catalogScrollController;
  final ScrollController wardrobeScrollController;

  const PanelContentWidget({
    super.key,
    required this.selectedTabIndex,
    required this.onTabSelected,
    required this.catalogScrollController,
    required this.wardrobeScrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final panelBg = theme.scaffoldBackgroundColor;

    return Column(
      children: [
        SizedBox(
          height: 20,
          child: Center(
            child: Container(
              height: 5,
              width: 230,
              decoration: BoxDecoration(
                color:
                    theme.brightness == Brightness.dark
                        ? Colors.white24
                        : const Color.fromARGB(255, 217, 217, 217),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: panelBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildTabButton(context, 'Каталог', 0),
                    _buildTabButton(context, 'Гардероб', 1),
                  ],
                ),
                Expanded(
                  child: PageTransitionSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation, secondaryAnimation) {
                      return SharedAxisTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.horizontal,
                        child: child,
                      );
                    },
                    child:
                        selectedTabIndex == 0
                            ? CatalogTab(
                              key: const ValueKey('catalog'),
                              scrollController: catalogScrollController,
                            )
                            : WardrobeTab(
                              key: const ValueKey('wardrobe'),
                              scrollController: wardrobeScrollController,
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(BuildContext context, String title, int index) {
    final theme = Theme.of(context);
    final inactiveBg = theme.scaffoldBackgroundColor;
    final inactiveTextColor =
        theme.brightness == Brightness.dark ? Colors.white70 : Colors.black;
    bool isSelected = selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : inactiveBg,
            borderRadius:
                index == 0
                    ? const BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      bottomRight: Radius.circular(24.0),
                    )
                    : const BorderRadius.only(
                      topRight: Radius.circular(24.0),
                      bottomLeft: Radius.circular(24.0),
                    ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'SFPro-Medium',
                color: isSelected ? Colors.white : inactiveTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
