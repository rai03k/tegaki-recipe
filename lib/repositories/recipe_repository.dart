import 'package:drift/drift.dart';
import '../models/database.dart';
import '../models/ingredient.dart';

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
    List<RecipeIngredient>? ingredients,
  }) async {
    // トランザクションで レシピと材料を一緒に保存
    return await _database.transaction(() async {
      // レシピを保存
      final recipeId = await _database.into(_database.recipes).insert(
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

      // 材料を保存
      if (ingredients != null && ingredients.isNotEmpty) {
        for (int i = 0; i < ingredients.length; i++) {
          final ingredient = ingredients[i];
          await _database.into(_database.ingredients).insert(
            IngredientsCompanion(
              recipeId: Value(recipeId),
              name: Value(ingredient.name),
              amount: Value(ingredient.amount),
              sortOrder: Value(i), // 入力順で並び順を設定
            ),
          );
        }
      }

      return recipeId;
    });
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
    List<RecipeIngredient>? ingredients,
  }) async {
    return await _database.transaction(() async {
      // レシピ情報を更新
      final recipeUpdated = await _database.update(_database.recipes).replace(
        RecipesCompanion(
          id: Value(id),
          title: title != null ? Value(title) : const Value.absent(),
          imagePath: imagePath != null ? Value(imagePath) : const Value.absent(),
          cookingTimeMinutes: cookingTimeMinutes != null ? Value(cookingTimeMinutes) : const Value.absent(),
          memo: memo != null ? Value(memo) : const Value.absent(),
          instructions: instructions != null ? Value(instructions) : const Value.absent(),
          referenceUrl: referenceUrl != null ? Value(referenceUrl) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // 材料を更新する場合
      if (ingredients != null) {
        // 既存の材料をすべて削除
        await (_database.delete(_database.ingredients)
              ..where((tbl) => tbl.recipeId.equals(id)))
            .go();

        // 新しい材料を追加
        for (int i = 0; i < ingredients.length; i++) {
          final ingredient = ingredients[i];
          await _database.into(_database.ingredients).insert(
            IngredientsCompanion(
              recipeId: Value(id),
              name: Value(ingredient.name),
              amount: Value(ingredient.amount),
              sortOrder: Value(i),
            ),
          );
        }
      }

      return recipeUpdated;
    });
  }

  // レシピを削除
  Future<int> deleteRecipe(int id) async {
    return await (_database.delete(_database.recipes)
          ..where((recipe) => recipe.id.equals(id)))
        .go();
  }
}