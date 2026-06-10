import 'package:flutter/material.dart';

class CategorySelector extends StatefulWidget {
  final Map<String, Map<String, List<String>>> categories;
  final bool isExpanded;
  final Map<String, bool> expandedCategories;
  final Map<String, bool> expandedSubcategories;
  final Function(String?, String?, String?) onCategorySelected;
  final Function(bool) onExpandChanged;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.isExpanded,
    required this.expandedCategories,
    required this.expandedSubcategories,
    required this.onCategorySelected,
    required this.onExpandChanged,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  String? _category;
  String? _subcategory;
  String? _subSubcategory;

  // Кастомная кнопка с категориями
  Widget _buildCategorySelector() {
    // Вычисляем высоту кнопки в зависимости от содержимого
    double buttonHeight = 49.0; // Базовая высота кнопки
    if (widget.isExpanded) {
      // Добавляем высоту для категорий
      buttonHeight += widget.categories.keys.length * 36.7;
      // Добавляем высоту для подкатегорий раскрытых категорий
      for (var category in widget.categories.keys) {
        if (widget.expandedCategories[category] ?? false) {
          buttonHeight += widget.categories[category]!.keys.length * 36.7;
          // Добавляем высоту для подподкатегорий раскрытых подкатегорий
          for (var subcategory in widget.categories[category]!.keys) {
            if (widget.expandedSubcategories['$category-$subcategory'] ??
                false) {
              buttonHeight +=
                  widget.categories[category]![subcategory]!.length * 36;
            }
          }
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              widget.onExpandChanged(!widget.isExpanded);
              if (!widget.isExpanded) {
                // Сбрасываем выбор, если ничего не выбрано
                if (_subSubcategory == null) {
                  _category = null;
                  _subcategory = null;
                  _subSubcategory = null;
                  widget.onCategorySelected(null, null, null);
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.only(
                top: 10,
                left: 12,
                right: 12,
                bottom: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _subSubcategory ?? 'Выберите категорию',
                    style: TextStyle(
                      fontSize: 17,
                      color:
                          _subSubcategory == null
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Icon(
                    widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color.fromARGB(255, 100, 100, 100),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            height: widget.isExpanded ? buttonHeight - 49.0 : 0,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: widget.isExpanded ? _buildCategoryOptions() : [],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryOptions() {
    List<Widget> categoryWidgets = [];
    int index = 0;
    for (var category in widget.categories.keys) {
      categoryWidgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  // Если категория уже выбрана, сворачиваем её
                  if (widget.expandedCategories[category] ?? false) {
                    widget.expandedCategories[category] = false;
                    widget.expandedSubcategories.updateAll(
                      (key, value) =>
                          key.startsWith('$category-') ? false : value,
                    );
                    if (_category == category) {
                      _category = null;
                      _subcategory = null;
                      _subSubcategory = null;
                      widget.onCategorySelected(null, null, null);
                    }
                  } else {
                    // Сворачиваем все остальные категории
                    widget.expandedCategories.updateAll((key, value) => false);
                    widget.expandedCategories[category] = true;
                    widget.expandedSubcategories.updateAll(
                      (key, value) => false,
                    );
                    _category = category;
                    _subcategory = null;
                    _subSubcategory = null;
                    widget.onCategorySelected(category, null, null);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontFamily:
                              widget.expandedCategories[category] ?? false
                                  ? 'SFPro-Bold'
                                  : 'SFPro-Light',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        (widget.expandedCategories[category] ?? false)
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: const Color.fromARGB(255, 100, 100, 100),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (index < widget.categories.keys.length - 1)
              Divider(
                color: Theme.of(context).colorScheme.outline,
                thickness: 1,
                height: 1,
              ),
            if (widget.expandedCategories[category] ?? false) ...[
              ..._buildSubcategoryOptions(category),
            ],
          ],
        ),
      );
      index++;
    }
    return categoryWidgets;
  }

  List<Widget> _buildSubcategoryOptions(String category) {
    List<Widget> subcategoryWidgets = [];
    for (var subcategory in widget.categories[category]!.keys) {
      subcategoryWidgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  // Если подкатегория уже выбрана, сворачиваем её
                  if (widget.expandedSubcategories['$category-$subcategory'] ??
                      false) {
                    widget.expandedSubcategories['$category-$subcategory'] =
                        false;
                    if (_subcategory == subcategory) {
                      _subcategory = null;
                      _subSubcategory = null;
                      widget.onCategorySelected(_category, null, null);
                    }
                  } else {
                    // Сворачиваем все остальные подкатегории в этой категории
                    widget.expandedSubcategories.updateAll(
                      (key, value) =>
                          key.startsWith('$category-') ? false : value,
                    );
                    widget.expandedSubcategories['$category-$subcategory'] =
                        true;
                    _subcategory = subcategory;
                    _subSubcategory = null;
                    widget.onCategorySelected(_category, subcategory, null);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 32),
                      child: Text(
                        subcategory,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontFamily:
                              widget.expandedSubcategories['$category-$subcategory'] ??
                                      false
                                  ? 'SFPro-Bold'
                                  : 'SFPro-Light',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        (widget.expandedSubcategories['$category-$subcategory'] ??
                                false)
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: const Color.fromARGB(255, 100, 100, 100),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              color: Theme.of(context).colorScheme.outline,
              thickness: 1,
              height: 1,
            ),
            if (widget.expandedSubcategories['$category-$subcategory'] ??
                false) ...[
              ..._buildSubSubcategoryOptions(category, subcategory),
            ],
          ],
        ),
      );
    }
    return subcategoryWidgets;
  }

  List<Widget> _buildSubSubcategoryOptions(
    String category,
    String subcategory,
  ) {
    List<Widget> subSubcategoryWidgets = [];
    for (var subSubcategory in widget.categories[category]![subcategory]!) {
      subSubcategoryWidgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _subSubcategory = subSubcategory;
                  widget.onExpandChanged(false);
                  // Сбрасываем раскрытие всех категорий и подкатегорий
                  widget.expandedCategories.updateAll((key, value) => false);
                  widget.expandedSubcategories.updateAll((key, value) => false);
                  widget.onCategorySelected(
                    _category,
                    _subcategory,
                    subSubcategory,
                  );
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 52),
                      child: Text(
                        subSubcategory,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontFamily: 'SFPro-Light',
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: SizedBox(width: 20),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              color: Theme.of(context).colorScheme.outline,
              thickness: 1,
              height: 1,
            ),
          ],
        ),
      );
    }
    return subSubcategoryWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return _buildCategorySelector();
  }
}
