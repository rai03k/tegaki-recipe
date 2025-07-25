import 'package:drift/drift.dart';
import '../models/database.dart';

class RecipeRepository {
  final TegakiDatabase _database;

  RecipeRepository(this._database);

  // レシピ本のレシピ一覧を取得
  Future<List<Recipe>> getRecipesByBookId(int recipeBookId) async {
    return await (_database.select(_database.recipes)
          ..where((recipe) => recipe.recipeBookId.equals(recipeBookId))
          ..orderBy([(recipe) => OrderingTerm.asc(recipe.createdAt)]))
        .get();
  }

  // IDでレシピを取得
  Future<Recipe?> getRecipeById(int id) async {
    return await (_database.select(_database.recipes)
          ..where((recipe) => recipe.id.equals(id)))
        .getSingleOrNull();
  }

  // レシピを作成
  Future<int> createRecipe({
    required int recipeBookId,
    required String title,
    String? imagePath,
    int? cookingTimeMinutes,
    String? memo,
    String? instructions,
    String? referenceUrl,
  }) async {
    return await _database.into(_database.recipes).insert(
          RecipesCompanion(
            recipeBookId: Value(recipeBookId),
            title: Value(title),
            imagePath: Value(imagePath),
            cookingTimeMinutes: Value(cookingTimeMinutes),
            memo: Value(memo),
            instructions: Value(instructions),
            referenceUrl: Value(referenceUrl),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  // レシピを更新
  Future<bool> updateRecipe({
    required int id,
    String? title,
    String? imagePath,
    int? cookingTimeMinutes,
    String? memo,
    String? instructions,
    String? referenceUrl,
  }) async {
    final companion = RecipesCompanion(
      id: Value(id),
      updatedAt: Value(DateTime.now()),
    );

    if (title != null) companion.copyWith(title: Value(title));
    if (imagePath != null) companion.copyWith(imagePath: Value(imagePath));
    if (cookingTimeMinutes != null) companion.copyWith(cookingTimeMinutes: Value(cookingTimeMinutes));
    if (memo != null) companion.copyWith(memo: Value(memo));
    if (instructions != null) companion.copyWith(instructions: Value(instructions));
    if (referenceUrl != null) companion.copyWith(referenceUrl: Value(referenceUrl));

    return await _database.update(_database.recipes).replace(companion);
  }

  // レシピを削除
  Future<int> deleteRecipe(int id) async {
    return await (_database.delete(_database.recipes)
          ..where((recipe) => recipe.id.equals(id)))
        .go();
  }
}