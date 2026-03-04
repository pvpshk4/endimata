import 'package:go_router/go_router.dart';
import 'package:endimata/common/presentation/layouts/main_layout.dart';
import 'package:endimata/common/photo_upload/presentation/pages/clothes_category_selection_page.dart';
import 'package:endimata/features/catalog/presentation/pages/catalog_page.dart';
import 'package:endimata/features/home/presentation/pages/home_page.dart';
import 'package:endimata/features/profile/presentation/pages/profile_page.dart';
import 'package:endimata/features/profile/presentation/pages/deleted_photos_page.dart';
import 'package:endimata/features/wardrobe/presentation/pages/wardrobe_page.dart';
import 'package:endimata/features/wardrobe/presentation/pages/subcategories_page.dart';
import 'package:endimata/features/wardrobe/presentation/pages/products_page.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(
          navigationShell: navigationShell,
          showCentralButton: true,
          showBottomNavBar: true,
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/', builder: (_, __) => const HomePage())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/catalog', builder: (_, __) => const CatalogPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/wardrobe',
              builder: (_, __) => const WardrobePage(),
              routes: [
                GoRoute(
                  path: 'subcategories/:category',
                  builder: (context, state) {
                    final category = state.pathParameters['category']!;
                    return SubcategoriesPage(category: category);
                  },
                ),
                GoRoute(
                  path: 'products/:category/:subcategory',
                  builder: (context, state) {
                    final category = state.pathParameters['category']!;
                    final subcategory = state.pathParameters['subcategory']!;
                    return ProductsPage(
                      category: category,
                      subcategory: subcategory,
                      extra: state.extra as Map<String, dynamic>?,
                    );
                  },
                ),
                GoRoute(
                  path: 'clothes-category-selection',
                  builder: (context, state) {
                    final imagePath = state.extra as String;
                    return ClothesCategorySelectionPage(imagePath: imagePath);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfilePage(),
              routes: [
                GoRoute(
                  path: 'deleted-photos',
                  builder: (context, state) => const DeletedPhotosPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
