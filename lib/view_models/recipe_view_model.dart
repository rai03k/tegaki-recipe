import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/recipe_state.dart';
import '../models/ingredient.dart';
import '../repositories/recipe_repository.dart';
import '../services/database_service.dart';

part 'recipe_view_model.g.dart';

/// レシピ一覧の状態管理を行うNotifier
@riverpod
class RecipeNotifier extends _$RecipeNotifier {
  late final RecipeRepository _repository;

  @override
  RecipeState build() {
    _repository = RecipeRepository(DatabaseService.instance.database);
    return const RecipeState();
  }

  /// 指定されたレシピ本のレシピ一覧を読み込む
  Future<void> loadRecipesByBookId(int recipeBookId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final recipes = await _repository.getRecipesByBookId(recipeBookId);
      state = state.copyWith(
        recipes: recipes,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('レシピの読み込みに失敗しました: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'レシピの読み込みに失敗しました',
      );
    }
  }

  /// レシピを再読み込みする
  Future<void> refresh(int recipeBookId) async {
    await loadRecipesByBookId(recipeBookId);
  }

  /// 新しいレシピを作成
  Future<bool> createRecipe({
    required int recipeBookId,
    required String title,
    String? imagePath,
    int? cookingTimeMinutes,
    String? memo,
    String? instructions,
    String? referenceUrl,
    List<RecipeIngredient>? ingredients,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await _repository.createRecipe(
        recipeBookId: recipeBookId,
        title: title,
        imagePath: imagePath,
        cookingTimeMinutes: cookingTimeMinutes,
        memo: memo,
        instructions: instructions,
        referenceUrl: referenceUrl,
        ingredients: ingredients,
      );
      // 作成後に一覧を再読み込み
      await loadRecipesByBookId(recipeBookId);
      return true;
    } catch (e) {
      debugPrint('レシピの作成に失敗しました: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'レシピの作成に失敗しました',
      );
      return false;
    }
  }

  /// レシピを更新
  Future<bool> updateRecipe({
    required int id,
    required String title,
    String? imagePath,
    int? cookingTimeMinutes,
    String? memo,
    String? instructions,
    String? referenceUrl,
    List<RecipeIngredient>? ingredients,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final success = await _repository.updateRecipe(
        id: id,
        title: title,
        imagePath: imagePath,
        cookingTimeMinutes: cookingTimeMinutes,
        memo: memo,
        instructions: instructions,
        referenceUrl: referenceUrl,
        ingredients: ingredients,
      );
      
      if (success) {
        // 更新後に状態を更新（現在のレシピリストを再読み込み）
        if (state.recipes.isNotEmpty) {
          final updatedRecipe = await _repository.getRecipeById(id);
          if (updatedRecipe != null) {
            final updatedRecipes = state.recipes.map((recipe) {
              return recipe.id == id ? updatedRecipe : recipe;
            }).toList();
            state = state.copyWith(
              recipes: updatedRecipes,
              isLoading: false,
            );
          }
        }
      }
      
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      debugPrint('レシピの更新に失敗しました: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'レシピの更新に失敗しました',
      );
      return false;
    }
  }

  /// レシピを削除
  Future<bool> deleteRecipe(int recipeId, int recipeBookId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await _repository.deleteRecipe(recipeId);
      // 削除後に一覧を再読み込み
      await loadRecipesByBookId(recipeBookId);
      return true;
    } catch (e) {
      debugPrint('レシピの削除に失敗しました: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'レシピの削除に失敗しました',
      );
      return false;
    }
  }
}