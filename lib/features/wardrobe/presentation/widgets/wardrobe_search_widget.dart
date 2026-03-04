import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:endimata/features/wardrobe/presentation/bloc/wardrobe_bloc.dart';
import 'package:endimata/features/wardrobe/presentation/bloc/wardrobe_event.dart';
import 'package:endimata/features/wardrobe/presentation/bloc/wardrobe_state.dart';

class WardrobeSearchWidget extends StatefulWidget {
  final String basePath;
  final Function(BuildContext, String, String, Map<String, dynamic>)?
  onNavigate;
  final Function(String)? onScrollToSubSubcategory;

  const WardrobeSearchWidget({
    super.key,
    required this.basePath,
    this.onNavigate,
    this.onScrollToSubSubcategory,
  });

  @override
  State<WardrobeSearchWidget> createState() => _WardrobeSearchWidgetState();
}

class _WardrobeSearchWidgetState extends State<WardrobeSearchWidget> {
  final TextEditingController _textController = TextEditingController();
  final SearchController _searchController = SearchController();
  List<Map<String, String>> _allSubSubcategories = [];
  List<Map<String, String>> _filteredSubSubcategories = [];
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onSearchChanged);
    _textController.dispose();

    // Добавляем задержку перед dispose SearchController
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) return; // Убеждаемся, что виджет всё ещё не смонтирован
      _searchController.dispose();
    });

    super.dispose();
  }

  void _onSearchChanged() {
    if (_isNavigating) return;

    final query = _textController.text.toLowerCase();
    setState(() {
      _filteredSubSubcategories =
          query.isEmpty
              ? _allSubSubcategories
              : _allSubSubcategories
                  .where(
                    (item) =>
                        item['subSubcategory']!.toLowerCase().contains(query),
                  )
                  .toList();
    });
  }

  void _navigateToProductsPage(
    String category,
    String subcategory,
    String subSubcategory,
  ) {
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
      _textController.text = subSubcategory;
    });

    FocusScope.of(context).unfocus();
    _searchController.closeView(null);

    // Добавляем задержку, чтобы дать SearchAnchor время завершить анимацию
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      // Если передан onScrollToSubSubcategory, прокручиваем страницу
      if (widget.onScrollToSubSubcategory != null) {
        widget.onScrollToSubSubcategory!(subSubcategory);
        setState(() {
          _isNavigating = false;
        });
        return;
      }

      // Иначе выполняем навигацию
      if (widget.onNavigate != null) {
        widget.onNavigate!(context, category, subcategory, {
          'subSubcategory': subSubcategory,
          'scrollToSubSubcategory': true,
        });
      } else {
        final encodedCategory = Uri.encodeComponent(category);
        final encodedSubcategory = Uri.encodeComponent(subcategory);
        final route =
            '${widget.basePath}/products/$encodedCategory/$encodedSubcategory';

        context
            .push(
              route,
              extra: {
                'subSubcategory': subSubcategory,
                'scrollToSubSubcategory': true,
              },
            )
            .then((_) {
              if (mounted) {
                setState(() {
                  _isNavigating = false;
                });
              }
            })
            .catchError((e) {
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Ошибка навигации: $e')));
                setState(() {
                  _isNavigating = false;
                });
              }
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WardrobeBloc, WardrobeState>(
      listener: (context, state) {
        if (state is AllSubSubcategoriesLoadedState) {
          setState(() {
            _allSubSubcategories = state.allSubSubcategories;
            _filteredSubSubcategories = _allSubSubcategories;
          });
        } else if (state is WardrobeErrorState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: SearchAnchor(
          searchController: _searchController,
          isFullScreen: false,
          viewBuilder:
              (suggestions) => ListView(children: suggestions.toList()),
          builder:
              (context, controller) => SearchBar(
                controller: _textController,
                padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16),
                ),
                onTap: () {
                  if (_isNavigating) return;
                  context.read<WardrobeBloc>().add(
                    LoadAllSubSubcategoriesEvent(),
                  );
                  controller.openView();
                },
                onChanged: (_) {
                  if (_isNavigating) return;
                  controller.openView();
                },
                hintText: 'Поиск',
                leading: const Icon(Icons.search),
                elevation: const WidgetStatePropertyAll(4),
                backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.surface,
                ),
                shape: const WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                trailing: [
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _textController.clear();
                      controller.closeView(null);
                    },
                  ),
                ],
              ),
          suggestionsBuilder: (context, controller) {
            if (_filteredSubSubcategories.isEmpty) {
              return [
                ListTile(
                  title: Text(
                    'Ничего не найдено',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ];
            }

            return _filteredSubSubcategories.map((item) {
              final category = item['category']!;
              final subcategory = item['subcategory']!;
              final subSubcategory = item['subSubcategory']!;
              return ListTile(
                title: Text(subSubcategory),
                subtitle: Text('$category > $subcategory'),
                onTap:
                    () => _navigateToProductsPage(
                      category,
                      subcategory,
                      subSubcategory,
                    ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
