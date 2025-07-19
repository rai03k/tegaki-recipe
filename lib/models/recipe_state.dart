import 'package:freezed_annotation/freezed_annotation.dart';
import 'database.dart';

part 'recipe_state.freezed.dart';

/// レシピ一覧の状態を管理するクラス
@freezed
class RecipeState with _$RecipeState {
  const factory RecipeState({
    @Default([]) List<Recipe> recipes,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _RecipeState;
}