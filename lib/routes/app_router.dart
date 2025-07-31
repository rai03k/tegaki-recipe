import 'package:go_router/go_router.dart';
import 'package:tegaki_recipe/models/ingredient.dart';
import '../views/home_screen.dart';
import '../views/create_recipe_book_screen.dart';
import '../views/edit_recipe_book_screen.dart';
import '../views/table_of_contents_screen.dart';
import '../views/create_recipe_screen.dart';
import '../views/ingredient_selection_screen.dart';
import '../views/timer_screen.dart';
import '../views/recipe_detail_screen.dart';
import '../views/shopping_memo_screen.dart';
import '../views/settings_screen.dart';
import '../models/database.dart';
import '../utils/page_transitions.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder:
            (context, state) => PageTransitions.fadeScaleTransition(
              context,
              state,
              const HomeScreen(),
            ),
      ),
      GoRoute(
        path: '/create-recipe-book',
        pageBuilder:
            (context, state) => PageTransitions.fadeSlideTransition(
              context,
              state,
              const CreateRecipeBookScreen(),
            ),
      ),
      GoRoute(
        path: '/edit-recipe-book/:recipeBookId',
        pageBuilder: (context, state) {
          final recipeBook = state.extra as RecipeBook;
          return PageTransitions.fadeSlideTransition(
            context,
            state,
            EditRecipeBookScreen(recipeBook: recipeBook),
          );
        },
      ),
      GoRoute(
        path: '/table-of-contents/:recipeBookId',
        pageBuilder: (context, state) {
          final recipeBook = state.extra as RecipeBook;
          return PageTransitions.fadeScaleTransition(
            context,
            state,
            TableOfContentsScreen(recipeBook: recipeBook),
          );
        },
      ),
      GoRoute(
        path: '/create-recipe/:recipeBookId',
        pageBuilder: (context, state) {
          final recipeBook = state.extra as RecipeBook;
          return PageTransitions.fadeSlideTransition(
            context,
            state,
            CreateRecipeScreen(recipeBook: recipeBook),
          );
        },
      ),
      GoRoute(
        path: '/ingredient-selection',
        pageBuilder: (context, state) {
          final existingIngredients = state.extra as List<RecipeIngredient>?;
          return PageTransitions.rippleTransition(
            context,
            state,
            IngredientSelectionScreen(existingIngredients: existingIngredients),
          );
        },
      ),
      GoRoute(
        path: '/timer',
        pageBuilder:
            (context, state) => PageTransitions.fadeTransition(
              context,
              state,
              const TimerScreen(),
            ),
      ),
      GoRoute(
        path: '/recipe-detail/:recipeId',
        pageBuilder: (context, state) {
          final recipe = state.extra as Recipe;
          return PageTransitions.fadeScaleTransition(
            context,
            state,
            RecipeDetailScreen(recipe: recipe),
          );
        },
      ),
      GoRoute(
        path: '/shopping-memo',
        pageBuilder:
            (context, state) => PageTransitions.fadeTransition(
              context,
              state,
              const ShoppingMemoScreen(),
            ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder:
            (context, state) => PageTransitions.fadeTransition(
              context,
              state,
              const SettingsScreen(),
            ),
      ),
    ],
  );
}
