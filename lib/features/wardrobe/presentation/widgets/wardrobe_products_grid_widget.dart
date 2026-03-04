import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:endimata/common/domain/entities/clothing_item_entity.dart';

class WardrobeProductsGridWidget extends StatelessWidget {
  final List<ClothingItemEntity> items;
  final ScrollController scrollController;
  final bool isLoadingMore;

  const WardrobeProductsGridWidget({
    super.key,
    required this.items,
    required this.scrollController,
    required this.isLoadingMore,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && !isLoadingMore) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      controller: scrollController,
      shrinkWrap: true, // Важно для вложенного GridView в ListView
      padding: EdgeInsets.only(left: 20, right: 20),
      physics:
          const NeverScrollableScrollPhysics(), // Отключаем прокрутку внутри GridView
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 0.78,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.memory(
                  base64Decode(item.imageUrl.split(',').last),
                  fit: BoxFit.fitWidth,
                  width: double.infinity,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(Icons.error),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
