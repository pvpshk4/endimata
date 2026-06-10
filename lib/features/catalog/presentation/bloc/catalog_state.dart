import 'package:equatable/equatable.dart';

class CatalogState extends Equatable {
  final List<String> navigationPath;
  final String? selectedCategory;
  final String? selectedSubcategory;
  final String? selectedSubSubcategory;

  const CatalogState({
    this.navigationPath = const [],
    this.selectedCategory,
    this.selectedSubcategory,
    this.selectedSubSubcategory,
  });

  CatalogState copyWith({
    List<String>? navigationPath,
    String? selectedCategory,
    String? selectedSubcategory,
    String? selectedSubSubcategory,
  }) {
    return CatalogState(
      navigationPath: navigationPath ?? this.navigationPath,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedSubcategory: selectedSubcategory ?? this.selectedSubcategory,
      selectedSubSubcategory:
          selectedSubSubcategory ?? this.selectedSubSubcategory,
    );
  }

  @override
  List<Object?> get props => [
    navigationPath,
    selectedCategory,
    selectedSubcategory,
    selectedSubSubcategory,
  ];
}
