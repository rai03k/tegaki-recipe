import 'package:freezed_annotation/freezed_annotation.dart';
import 'database.dart';

part 'recipe_book_state.freezed.dart';

/// レシピ本一覧の状態を管理するクラス
@freezed
class RecipeBookState with _$RecipeBookState {
  const factory RecipeBookState({
    @Default([]) List<RecipeBook> recipeBooks,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _RecipeBookState;
}