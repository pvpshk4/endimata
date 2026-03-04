import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:endimata/common/presentation/widgets/custom_scaffold.dart';
import '../bloc/wardrobe_bloc.dart';
import '../bloc/wardrobe_event.dart';
import '../bloc/wardrobe_state.dart';
import '../widgets/wardrobe_subcategories_list_widget.dart';
import '../widgets/wardrobe_search_widget.dart';

class SubcategoriesPage extends StatefulWidget {
  final String category;

  const SubcategoriesPage({super.key, required this.category});

  @override
  State<SubcategoriesPage> createState() => _SubcategoriesPageState();
}

class _SubcategoriesPageState extends State<SubcategoriesPage> {
  @override
  void initState() {
    super.initState();
    final currentState = context.read<WardrobeBloc>().state;
    if (currentState is! SubcategoriesLoadedState &&
        currentState is! WardrobeLoadedState) {
      context.read<WardrobeBloc>().add(LoadSubcategoriesEvent(widget.category));
    }
  }

  void _navigateToProducts(
    BuildContext navigationContext,
    String category,
    String subcategory,
    Map<String, dynamic> extra,
  ) {
    final encodedCategory = Uri.encodeComponent(category);
    final encodedSubcategory = Uri.encodeComponent(subcategory);
    final route = '/wardrobe/products/$encodedCategory/$encodedSubcategory';

    extra['previousRoute'] = '/wardrobe/subcategories/$encodedCategory';

    // ignore: body_might_complete_normally_catch_error
    navigationContext.push(route, extra: extra).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка навигации: $e')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final encodedCategory = Uri.encodeComponent(widget.category);
    final basePath = '/wardrobe/subcategories/$encodedCategory';

    return CustomScaffold(
      appBar: AppBar(
        title: Text(widget.category, style: const TextStyle(fontSize: 20)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<WardrobeBloc>().add(LoadCategoriesEvent());
            context.pop();
          },
        ),
      ),
      body: BlocBuilder<WardrobeBloc, WardrobeState>(
        buildWhen: (previous, current) {
          return current is WardrobeLoadingState ||
              current is SubcategoriesLoadedState ||
              current is WardrobeLoadedState ||
              current is WardrobeErrorState;
        },
        builder: (context, state) {
          if (state is WardrobeLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SubcategoriesLoadedState ||
              state is WardrobeLoadedState) {
            final subcategories = state.subcategories;

            if (subcategories.isEmpty) {
              context.read<WardrobeBloc>().add(
                LoadSubcategoriesEvent(widget.category),
              );
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  WardrobeSearchWidget(
                    basePath: basePath,
                    onNavigate: _navigateToProducts,
                  ),
                  Expanded(
                    child: WardrobeSubcategoriesListWidget(
                      category: widget.category,
                      subcategories: subcategories,
                    ),
                  ),
                ],
              ),
            );
          } else if (state is WardrobeErrorState) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Неизвестное состояние'));
        },
      ),
    );
  }
}
