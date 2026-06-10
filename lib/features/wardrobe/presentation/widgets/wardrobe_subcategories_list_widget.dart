import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'wardrobe_subcategory_widget.dart';

class WardrobeSubcategoriesListWidget extends StatelessWidget {
  final String category;
  final List<String> subcategories;

  const WardrobeSubcategoriesListWidget({
    super.key,
    required this.category,
    required this.subcategories,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: subcategories.length,
      itemBuilder: (context, index) {
        final subcategory = subcategories[index];
        final encodedCategory = Uri.encodeComponent(category);
        final encodedSubcategory = Uri.encodeComponent(subcategory);
        return WardrobeSubcategoryWidget(
          title: subcategory,
          onTap:
              () => context.go(
                '/wardrobe/products/$encodedCategory/$encodedSubcategory',
              ),
        );
      },
    );
  }
}
