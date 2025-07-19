import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/home_screen.dart';
import '../views/create_recipe_book_screen.dart';

class AppRouter {
  static GoRouter createRouter({
    required VoidCallback onThemeToggle,
    required bool isDarkMode,
  }) {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => HomeScreen(
            onThemeToggle: onThemeToggle,
            isDarkMode: isDarkMode,
          ),
        ),
        GoRoute(
          path: '/create-recipe-book',
          builder: (context, state) => CreateRecipeBookScreen(
            isDarkMode: isDarkMode,
          ),
        ),
      ],
    );
  }
}