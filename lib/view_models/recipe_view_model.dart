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