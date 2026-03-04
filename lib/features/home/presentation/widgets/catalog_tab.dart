import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:endimata/config/app_constants.dart';
import 'package:endimata/features/home/presentation/bloc/home_bloc.dart';
import 'package:endimata/features/home/presentation/bloc/home_event.dart';
import 'package:endimata/features/home/presentation/bloc/home_state.dart';
import 'package:animations/animations.dart';

class CatalogTab extends StatelessWidget {
  final ScrollController scrollController;

  const CatalogTab({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<HomeBloc, HomeState>(
          buildWhen:
              (previous, current) =>
                  previous.catalogCategory != current.catalogCategory ||
                  previous.catalogSubcategory != current.catalogSubcategory ||
                  previous.catalogSubSubcategory !=
                      current.catalogSubSubcategory,
          builder: (context, state) {
            final currentCategories = categories.keys.toList();
            final currentSubcategories =
                state.catalogCategory.isNotEmpty
                    ? categories[state.catalogCategory]!.keys.toList()
                    : [];
            final currentSubSubcategories =
                state.catalogSubcategory.isNotEmpty
                    ? categories[state.catalogCategory]![state
                        .catalogSubcategory]!
                    : [];

            final hasSubSubcategories = state.catalogSubSubcategory.isEmpty;

            final currentSelection =
                state.catalogSubSubcategory.isNotEmpty
                    ? state.catalogSubSubcategory
                    : state.catalogSubcategory.isNotEmpty
                    ? state.catalogSubcategory
                    : state.catalogCategory.isNotEmpty
                    ? state.catalogCategory
                    : null;

            final currentLevel =
                state.catalogSubSubcategory.isNotEmpty
                    ? 2
                    : state.catalogSubcategory.isNotEmpty
                    ? 1
                    : state.catalogCategory.isNotEmpty
                    ? 0
                    : -1;

            final items =
                state.catalogSubcategory.isNotEmpty
                    ? currentSubSubcategories
                    : state.catalogCategory.isNotEmpty
                    ? currentSubcategories
                    : currentCategories;

            return PageTransitionSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation, secondaryAnimation) {
                return FadeThroughTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  child: child,
                );
              },
              child: Container(
                key: ValueKey(
                  '${state.catalogCategory}-${state.catalogSubcategory}-${state.catalogSubSubcategory}',
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0,
                ),
                height: 40,
                child: ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(overscroll: false),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount:
                        (currentSelection != null ? 1 : 0) +
                        (hasSubSubcategories ? items.length : 0),
                    itemBuilder: (context, index) {
                      if (index == 0 && currentSelection != null) {
                        return GestureDetector(
                          onTap: () {
                            if (currentLevel == 0) {
                              context.read<HomeBloc>().add(
                                const ResetFilterEvent(isCatalogTab: true),
                              );
                            } else {
                              context.read<HomeBloc>().add(
                                GoToPreviousEvent(
                                  currentLevel,
                                  isCatalogTab: true,
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                currentSelection,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'SFPro-Bold',
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      if (hasSubSubcategories) {
                        final itemIndex =
                            index - (currentSelection != null ? 1 : 0);
                        final item = items[itemIndex];
                        return GestureDetector(
                          onTap: () {
                            if (state.catalogSubcategory.isNotEmpty) {
                              context.read<HomeBloc>().add(
                                SelectSubSubcategoryEvent(
                                  item,
                                  isCatalogTab: true,
                                ),
                              );
                            } else if (state.catalogCategory.isNotEmpty) {
                              context.read<HomeBloc>().add(
                                SelectSubcategoryEvent(
                                  item,
                                  isCatalogTab: true,
                                ),
                              );
                            } else {
                              context.read<HomeBloc>().add(
                                SelectCategoryEvent(item, isCatalogTab: true),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'SFPro-Light',
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            );
          },
        ),
        Expanded(
          child: BlocBuilder<HomeBloc, HomeState>(
            buildWhen:
                (previous, current) =>
                    previous.catalogItems != current.catalogItems,
            builder: (context, state) {
              return state.catalogItems.isEmpty
                  ? const Center(child: Text('Каталог пока пуст'))
                  : ListView.builder(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: state.catalogItems.length,
                    itemBuilder: (context, index) {
                      final item = state.catalogItems[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            base64Decode(item.image),
                            width: 80,
                            height: 100,
                            fit: BoxFit.fitWidth,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    const Icon(Icons.error),
                          ),
                        ),
                      );
                    },
                  );
            },
          ),
        ),
      ],
    );
  }
}
