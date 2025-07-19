import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/recipe_book_state.dart';
import '../repositories/recipe_book_repository.dart';
import '../services/database_service.dart';

part 'recipe_book_view_model.g.dart';

/// レシピ本一覧の状態管理を行うNotifier
@riverpod
class RecipeBookNotifier extends _$RecipeBookNotifier {
  late final RecipeBookRepository _repository;

  @override
  RecipeBookState build() {
    _repository = RecipeBookRepository(DatabaseService.instance.database);
    // 初期化時にレシピ本一覧を読み込み
    _loadRecipeBooks();
    return const RecipeBookState();
  }

  /// レシピ本一覧を読み込む
  Future<void> _loadRecipeBooks() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final recipeBooks = await _repository.getAllRecipeBooks();
      state = state.copyWith(
        recipeBooks: recipeBooks,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('レシピ本の読み込みに失敗しました: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'レシピ本の読み込みに失敗しました',
      );
    }
  }

  /// レシピ本一覧を再読み込みする（画面復帰時など）
  Future<void> refresh() async {
    await _loadRecipeBooks();
  }

  /// 新しいレシピ本を作成
  Future<bool> createRecipeBook({
    required String title,
    String? coverImagePath,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await _repository.createRecipeBook(
        title: title,
        coverImagePath: coverImagePath,
      );
      // 作成後に一覧を再読み込み
      await _loadRecipeBooks();
      return true;
    } catch (e) {
      debugPrint('レシピ本の作成に失敗しました: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'レシピ本の作成に失敗しました',
      );
      return false;
    }
  }

  /// レシピ本を削除
  Future<bool> deleteRecipeBook(int id) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await _repository.deleteRecipeBook(id);
      // 削除後に一覧を再読み込み
      await _loadRecipeBooks();
      return true;
    } catch (e) {
      debugPrint('レシピ本の削除に失敗しました: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'レシピ本の削除に失敗しました',
      );
      return false;
    }
  }
}