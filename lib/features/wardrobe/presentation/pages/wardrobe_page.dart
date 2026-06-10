import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:endimata/common/presentation/widgets/custom_scaffold.dart';
import '../bloc/wardrobe_bloc.dart';
import '../bloc/wardrobe_event.dart';
import '../bloc/wardrobe_state.dart';
import '../widgets/wardrobe_categories_list_widget.dart';
import '../widgets/wardrobe_search_widget.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  @override
  void initState() {
    super.initState();
    final currentState = context.read<WardrobeBloc>().state;
    if (currentState is! CategoriesLoadedState &&
        currentState is! WardrobeLoadedState) {
      context.read<WardrobeBloc>().add(LoadCategoriesEvent());
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
    return CustomScaffold(
      appBar: AppBar(
        title: const Text('Гардероб', style: TextStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: BlocBuilder<WardrobeBloc, WardrobeState>(
        buildWhen: (previous, current) {
          return current is WardrobeLoadingState ||
              current is CategoriesLoadedState ||
              current is WardrobeLoadedState ||
              current is WardrobeErrorState;
        },
        builder: (context, state) {
          if (state is WardrobeLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CategoriesLoadedState ||
              state is WardrobeLoadedState) {
            final categories =
                state is CategoriesLoadedState
                    ? state.categories
                    : (state as WardrobeLoadedState).categories;

            if (categories.isEmpty) {
              context.read<WardrobeBloc>().add(LoadCategoriesEvent());
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  WardrobeSearchWidget(
                    basePath: '/wardrobe',
                    onNavigate: _navigateToProducts,
                  ),
                  Expanded(
                    child: WardrobeCategoriesListWidget(categories: categories),
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

  @override
  void dispose() {
    super.dispose();
  }
}
