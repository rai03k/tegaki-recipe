import 'package:go_router/go_router.dart';
import '../views/home_screen.dart';
import '../views/create_recipe_book_screen.dart';

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
    ],
  );
}