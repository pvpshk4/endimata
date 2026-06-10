import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'wardrobe_category_widget.dart';

class WardrobeCategoriesListWidget extends StatelessWidget {
  final List<String> categories;

  const WardrobeCategoriesListWidget({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return WardrobeCategoryWidget(
          title: category,
          onTap: () => context.go('/wardrobe/subcategories/$category'),
        );
      },
    );
  }
}
