import 'package:go_router/go_router.dart';
import '../views/home_screen.dart';
import '../views/create_recipe_book_screen.dart';
import '../views/table_of_contents_screen.dart';
import '../views/create_recipe_screen.dart';
import '../views/ingredient_selection_screen.dart';
import '../views/timer_screen.dart';
import '../models/database.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/create-recipe-book',
        builder: (context, state) => const CreateRecipeBookScreen(),
      ),
      GoRoute(
        path: '/table-of-contents/:recipeBookId',
        builder: (context, state) {
          final recipeBook = state.extra as RecipeBook;
          return TableOfContentsScreen(recipeBook: recipeBook);
        },
      ),
      GoRoute(
        path: '/create-recipe/:recipeBookId',
        builder: (context, state) {
          final recipeBook = state.extra as RecipeBook;
          return CreateRecipeScreen(recipeBook: recipeBook);
        },
      ),
      GoRoute(
        path: '/ingredient-selection',
        builder: (context, state) => const IngredientSelectionScreen(),
      ),
      GoRoute(
        path: '/timer',
        builder: (context, state) => const TimerScreen(),
      ),
    ],
  );
}