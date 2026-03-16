import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:endimata/common/domain/entities/clothing_item_entity.dart';
import 'package:endimata/config/theme/app_colors.dart';

class WardrobeProductsGridWidget extends StatelessWidget {
  final List<ClothingItemEntity> items;
  final ScrollController scrollController;
  final bool isLoadingMore;
  final Set<String> selectedItems;
  final Function(ClothingItemEntity)? onItemTapped;
  final Function(ClothingItemEntity)? onItemLongPressed;

  const WardrobeProductsGridWidget({
    super.key,
    required this.items,
    required this.scrollController,
    required this.isLoadingMore,
    this.selectedItems = const {},
    this.onItemTapped,
    this.onItemLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && !isLoadingMore) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      controller: scrollController,
      shrinkWrap: true,
      padding: const EdgeInsets.only(left: 20, right: 20),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 0.78,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedItems.contains(item.id);

        return GestureDetector(
          onTap: () => onItemTapped?.call(item),
          onLongPress: () => onItemLongPressed?.call(item),
          child: Stack(
            children: [
              // Карточка с фото
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side:
                      isSelected
                          ? const BorderSide(
                            color: AppColors.primaryColor,
                            width: 2,
                          )
                          : BorderSide.none,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          base64Decode(
                            item.imageUrl.contains(',')
                                ? item.imageUrl.split(',').last
                                : item.imageUrl,
                          ),
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Затемнение невыбранных в режиме выделения
              if (selectedItems.isNotEmpty && !isSelected)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                  ),
                ),

              // Чекбокс в режиме выделения
              if (selectedItems.isNotEmpty)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => onItemTapped?.call(item),
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
