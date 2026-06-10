import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:endimata/common/photo_upload/presentation/bloc/photo_upload_event.dart';
import '../../../../config/app_constants.dart';
import '../../../../core/resources/dialog_state.dart';
import '../bloc/photo_upload_bloc.dart';
import '../bloc/photo_upload_state.dart';
import '../widgets/photo_container.dart';
import '../widgets/category_selector.dart';
import '../widgets/apply_checkbox.dart';
import '../widgets/action_buttons.dart';

class ClothesCategorySelectionPage extends StatefulWidget {
  final String imagePath;

  const ClothesCategorySelectionPage({super.key, required this.imagePath});

  @override
  State<ClothesCategorySelectionPage> createState() =>
      _ClothesCategorySelectionPageState();
}

class _ClothesCategorySelectionPageState
    extends State<ClothesCategorySelectionPage> {
  String? _category;
  String? _subcategory;
  String? _subSubcategory;
  bool _applyImmediately = false;
  bool _isExpanded = false;
  final Map<String, bool> _expandedCategories = {};
  final Map<String, bool> _expandedSubcategories = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DialogState.setActiveDialog(ActiveDialog.clothesCategorySelection);
    });

    for (var category in categories.keys) {
      _expandedCategories[category] = false;
      for (var subcategory in categories[category]!.keys) {
        _expandedSubcategories['$category-$subcategory'] = false;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: BlocListener<PhotoUploadBloc, PhotoUploadState>(
            listener: (context, state) {
              if (state is PhotoUploadSuccessState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  DialogState.setActiveDialog(ActiveDialog.none);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Фото успешно загружено'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else if (state is PhotoUploadFailureState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  DialogState.setActiveDialog(ActiveDialog.none);
                });
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else if (state is PhotoUploadResetState) {
                Navigator.of(context).pop();
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          PhotoContainer(imagePath: widget.imagePath),
                          const SizedBox(height: 24.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: CategorySelector(
                              categories: categories,
                              isExpanded: _isExpanded,
                              expandedCategories: _expandedCategories,
                              expandedSubcategories: _expandedSubcategories,
                              onCategorySelected: (
                                category,
                                subcategory,
                                subSubcategory,
                              ) {
                                setState(() {
                                  _category = category;
                                  _subcategory = subcategory;
                                  _subSubcategory = subSubcategory;
                                });
                              },
                              onExpandChanged: (isExpanded) {
                                setState(() {
                                  _isExpanded = isExpanded;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Нижняя панель с safe zone для кнопок
                Padding(
                  padding: EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 8.0,
                    bottom: MediaQuery.of(context).padding.bottom + 16.0,
                  ),
                  child: Column(
                    children: [
                      ApplyCheckbox(
                        value: _applyImmediately,
                        onChanged: (value) {
                          setState(() {
                            _applyImmediately = value ?? false;
                          });
                        },
                      ),
                      const SizedBox(height: 8.0),
                      ActionButtons(
                        subSubcategory: _subSubcategory,
                        onCancel: () {
                          context.read<PhotoUploadBloc>().add(
                            CancelPhotoUploadEvent(),
                          );
                        },
                        onSave: () {
                          context.read<PhotoUploadBloc>().add(
                            SelectCategoryEvent(
                              category: _category!,
                              subcategory: _subcategory!,
                              subSubcategory: _subSubcategory!,
                            ),
                          );
                          context.read<PhotoUploadBloc>().add(
                            SavePhotoEvent(context),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
