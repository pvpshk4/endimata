import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:endimata/common/domain/entities/clothing_item_entity.dart';
import 'package:endimata/common/presentation/dialogs/confirmation_dialog.dart';
import 'package:endimata/common/presentation/widgets/custom_scaffold.dart';
import 'package:endimata/config/theme/app_colors.dart';
import '../bloc/wardrobe_bloc.dart';
import '../bloc/wardrobe_event.dart';
import '../bloc/wardrobe_state.dart';
import '../widgets/wardrobe_products_filter_widget.dart';
import '../widgets/wardrobe_products_grid_widget.dart';
import '../widgets/wardrobe_search_widget.dart';

class ProductsPage extends StatefulWidget {
  final String category;
  final String subcategory;
  final Map<String, dynamic>? extra;

  const ProductsPage({
    super.key,
    required this.category,
    required this.subcategory,
    this.extra,
  });

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ScrollController _scrollController = ScrollController();
  String _selectedSubSubcategory = '';
  final Map<String, GlobalKey> _sectionKeys = {};
  bool _shouldScrollToSubSubcategory = false;
  String? _previousRoute;

  // Выделение для удаления
  final Set<String> _selectedItemIds = {};
  // Хранит все items для поиска по id при удалении
  final Map<String, ClothingItemEntity> _allItemsById = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<WardrobeBloc>().add(
      LoadSubSubcategoriesEvent(widget.category, widget.subcategory),
    );

    if (widget.extra != null) {
      _selectedSubSubcategory = widget.extra!['subSubcategory'] ?? '';
      _shouldScrollToSubSubcategory =
          widget.extra!['scrollToSubSubcategory'] ?? false;
      _previousRoute = widget.extra!['previousRoute'];
      if (_selectedSubSubcategory.isNotEmpty) {
        _loadWardrobeItems();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll * 0.9) {
      context.read<WardrobeBloc>().add(
        LoadMoreWardrobeItemsEvent(
          username: 'default_user',
          category: widget.category,
          subcategory: widget.subcategory,
          subSubcategory: _selectedSubSubcategory,
          page: 0,
          limit: 0,
        ),
      );
    }
  }

  void _loadWardrobeItems() {
    context.read<WardrobeBloc>().add(
      LoadWardrobeEvent(
        username: 'default_user',
        category: widget.category,
        subcategory: widget.subcategory,
        subSubcategory: _selectedSubSubcategory,
      ),
    );
  }

  void _scrollToSection(String subSubcategory) {
    setState(() {
      _selectedSubSubcategory = subSubcategory;
    });

    final key = _sectionKeys[subSubcategory];
    if (key != null && key.currentContext != null) {
      final RenderBox renderBox =
          key.currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero).dy;
      const double offsetAdjustment = 154;
      _scrollController.animateTo(
        _scrollController.offset + position - offsetAdjustment,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onItemTapped(ClothingItemEntity item) {
    if (_selectedItemIds.isNotEmpty) {
      // Режим выделения — переключаем выделение
      setState(() {
        if (_selectedItemIds.contains(item.id)) {
          _selectedItemIds.remove(item.id);
        } else {
          _selectedItemIds.add(item.id);
        }
      });
    }
    // Если нет выделения — можно открыть детали (пока не реализовано)
  }

  void _onItemLongPressed(ClothingItemEntity item) {
    setState(() {
      _selectedItemIds.add(item.id);
      _allItemsById[item.id] = item;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedItemIds.clear();
    });
  }

  void _selectAll(Map<String, List<ClothingItemEntity>> groupedItems) {
    setState(() {
      for (final items in groupedItems.values) {
        for (final item in items) {
          _selectedItemIds.add(item.id);
          _allItemsById[item.id] = item;
        }
      }
    });
  }

  void _deleteSelected() {
    showDialog(
      context: context,
      builder:
          (dialogContext) => ConfirmationDialog(
            onConfirm: () {
              for (final id in _selectedItemIds.toList()) {
                context.read<WardrobeBloc>().add(DeleteClothingItemEvent(id));
              }
              _clearSelection();
              Navigator.pop(dialogContext);
            },
            onCancel: () => Navigator.pop(dialogContext),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return BlocConsumer<WardrobeBloc, WardrobeState>(
      listenWhen: (previous, current) {
        return current is WardrobeLoadedState && _shouldScrollToSubSubcategory;
      },
      listener: (context, state) {
        if (state is WardrobeLoadedState && _shouldScrollToSubSubcategory) {
          if (_selectedSubSubcategory.isNotEmpty) {
            _scrollToSection(_selectedSubSubcategory);
            _shouldScrollToSubSubcategory = false;
          }
        }
      },
      builder: (context, state) {
        // Собираем все items для индекса
        if (state is WardrobeLoadedState) {
          for (final items in state.groupedItems.values) {
            for (final item in items) {
              _allItemsById[item.id] = item;
            }
          }
        }

        final isSelectionMode = _selectedItemIds.isNotEmpty;
        Map<String, List<ClothingItemEntity>> groupedItems = {};
        if (state is WardrobeLoadedState) {
          groupedItems = state.groupedItems;
        } else if (state is WardrobeLoadingMoreState) {
          groupedItems = state.groupedItems;
        }

        final allSelected =
            groupedItems.isNotEmpty &&
            groupedItems.values
                .expand((items) => items)
                .every((item) => _selectedItemIds.contains(item.id));

        return Scaffold(
          appBar: AppBar(
            leading:
                isSelectionMode
                    ? IconButton(
                      icon: Icon(Icons.close, color: textColor),
                      onPressed: _clearSelection,
                    )
                    : IconButton(
                      icon: Icon(Icons.arrow_back, color: textColor),
                      onPressed: () {
                        if (_previousRoute != null &&
                            _previousRoute!.contains('subcategories')) {
                          context.go(
                            '/wardrobe/subcategories/${widget.category}',
                          );
                        } else {
                          context.go('/wardrobe');
                        }
                      },
                    ),
            title: Text(
              isSelectionMode
                  ? 'Выбрано: ${_selectedItemIds.length}'
                  : 'Гардероб',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'SFPro-Medium',
                color: textColor,
              ),
            ),
            centerTitle: true,
            actions:
                isSelectionMode
                    ? [
                      TextButton(
                        onPressed: () {
                          if (allSelected) {
                            _clearSelection();
                          } else {
                            _selectAll(groupedItems);
                          }
                        },
                        child: Text(
                          allSelected ? 'Снять выделение' : 'Выбрать все',
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontFamily: 'SFPro-Light',
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ]
                    : null,
          ),
          body: SafeArea(
            child: Stack(
              children: [
                // Основной контент
                BlocBuilder<WardrobeBloc, WardrobeState>(
                  buildWhen: (previous, current) {
                    return current is WardrobeLoadingState ||
                        current is SubSubcategoriesLoadedState ||
                        current is WardrobeLoadedState ||
                        current is WardrobeLoadingMoreState;
                  },
                  builder: (context, state) {
                    if (state is WardrobeLoadingState) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    List<String> subSubcategories = state.subSubcategories;
                    if (state is SubSubcategoriesLoadedState) {
                      if (_selectedSubSubcategory.isEmpty &&
                          subSubcategories.isNotEmpty) {
                        _selectedSubSubcategory = subSubcategories.first;
                        _loadWardrobeItems();
                      }
                      for (final subSub in subSubcategories) {
                        _sectionKeys[subSub] = GlobalKey();
                      }
                    }

                    bool isLoadingMore = false;
                    if (state is WardrobeLoadingMoreState) {
                      isLoadingMore = true;
                    }

                    return Column(
                      children: [
                        WardrobeSearchWidget(
                          basePath:
                              '/wardrobe/products/${widget.category}/${widget.subcategory}',
                          onScrollToSubSubcategory: _scrollToSection,
                        ),
                        if (subSubcategories.isNotEmpty)
                          WardrobeProductsFilterWidget(
                            subSubcategories: subSubcategories,
                            selectedSubSubcategory: _selectedSubSubcategory,
                            onSubSubcategorySelected: _scrollToSection,
                          ),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount:
                                groupedItems.keys.length +
                                (isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == groupedItems.keys.length &&
                                  isLoadingMore) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final subSubcategory = groupedItems.keys
                                  .elementAt(index);
                              final items = groupedItems[subSubcategory] ?? [];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    key: _sectionKeys[subSubcategory],
                                    padding: const EdgeInsets.only(
                                      top: 20,
                                      bottom: 20,
                                      left: 20,
                                    ),
                                    child: Text(
                                      subSubcategory.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontFamily: 'SFPro-Semibold',
                                      ),
                                    ),
                                  ),
                                  WardrobeProductsGridWidget(
                                    items: items,
                                    scrollController: ScrollController(),
                                    isLoadingMore: false,
                                    selectedItems: _selectedItemIds,
                                    onItemTapped: _onItemTapped,
                                    onItemLongPressed: (item) {
                                      _allItemsById[item.id] = item;
                                      _onItemLongPressed(item);
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // Нижняя панель удаления — как в профиле
                if (_selectedItemIds.isNotEmpty)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 25.0,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                          ),
                          onPressed: _deleteSelected,
                          child: const Text(
                            'Удалить',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'SFPro-Bold',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
