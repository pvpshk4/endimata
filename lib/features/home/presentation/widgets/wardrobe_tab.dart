import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:endimata/config/app_constants.dart';
import 'package:endimata/features/home/presentation/bloc/home_bloc.dart';
import 'package:endimata/features/home/presentation/bloc/home_event.dart';
import 'package:endimata/features/home/presentation/bloc/home_state.dart';
import 'package:animations/animations.dart';

class WardrobeTab extends StatelessWidget {
  final ScrollController scrollController;

  const WardrobeTab({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<HomeBloc, HomeState>(
          buildWhen:
              (previous, current) =>
                  previous.wardrobeCategory != current.wardrobeCategory ||
                  previous.wardrobeSubcategory != current.wardrobeSubcategory ||
                  previous.wardrobeSubSubcategory !=
                      current.wardrobeSubSubcategory,
          builder: (context, state) {
            final currentCategories = categories.keys.toList();
            final currentSubcategories =
                state.wardrobeCategory.isNotEmpty
                    ? categories[state.wardrobeCategory]!.keys.toList()
                    : [];
            final currentSubSubcategories =
                state.wardrobeSubcategory.isNotEmpty
                    ? categories[state.wardrobeCategory]![state
                        .wardrobeSubcategory]!
                    : [];

            final hasSubSubcategories = state.wardrobeSubSubcategory.isEmpty;

            final currentSelection =
                state.wardrobeSubSubcategory.isNotEmpty
                    ? state.wardrobeSubSubcategory
                    : state.wardrobeSubcategory.isNotEmpty
                    ? state.wardrobeSubcategory
                    : state.wardrobeCategory.isNotEmpty
                    ? state.wardrobeCategory
                    : null;

            final currentLevel =
                state.wardrobeSubSubcategory.isNotEmpty
                    ? 2
                    : state.wardrobeSubcategory.isNotEmpty
                    ? 1
                    : state.wardrobeCategory.isNotEmpty
                    ? 0
                    : -1;

            final items =
                state.wardrobeSubcategory.isNotEmpty
                    ? currentSubSubcategories
                    : state.wardrobeCategory.isNotEmpty
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
                  '${state.wardrobeCategory}-${state.wardrobeSubcategory}-${state.wardrobeSubSubcategory}',
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
                                const ResetFilterEvent(isCatalogTab: false),
                              );
                            } else {
                              context.read<HomeBloc>().add(
                                GoToPreviousEvent(
                                  currentLevel,
                                  isCatalogTab: false,
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
                            if (state.wardrobeSubcategory.isNotEmpty) {
                              context.read<HomeBloc>().add(
                                SelectSubSubcategoryEvent(
                                  item,
                                  isCatalogTab: false,
                                ),
                              );
                            } else if (state.wardrobeCategory.isNotEmpty) {
                              context.read<HomeBloc>().add(
                                SelectSubcategoryEvent(
                                  item,
                                  isCatalogTab: false,
                                ),
                              );
                            } else {
                              context.read<HomeBloc>().add(
                                SelectCategoryEvent(item, isCatalogTab: false),
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
                    previous.wardrobeItems != current.wardrobeItems,
            builder: (context, state) {
              return state.wardrobeItems.isEmpty
                  ? const Center(child: Text('Гардероб пока пуст'))
                  : ListView.builder(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: state.wardrobeItems.length,
                    itemBuilder: (context, index) {
                      final item = state.wardrobeItems[index];
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
