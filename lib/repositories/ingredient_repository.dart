import 'package:drift/drift.dart';
import '../models/database.dart';

class IngredientRepository {
  final TegakiDatabase _database;

  IngredientRepository(this._database);

  // レシピの材料一覧を取得
  Future<List<Ingredient>> getIngredientsByRecipeId(int recipeId) async {
    return await (_database.select(_database.ingredients)
          ..where((ingredient) => ingredient.recipeId.equals(recipeId))
          ..orderBy([(ingredient) => OrderingTerm.asc(ingredient.sortOrder)]))
        .get();
  }

  // 材料を追加
  Future<int> addIngredient({
    required int recipeId,
    required String name,
    String? amount,
    int sortOrder = 0,
  }) async {
    return await _database.into(_database.ingredients).insert(
          IngredientsCompanion(
            recipeId: Value(recipeId),
            name: Value(name),
            amount: Value(amount),
            sortOrder: Value(sortOrder),
          ),
        );
  }

  // 材料を更新
  Future<bool> updateIngredient({
    required int id,
    String? name,
    String? amount,
    int? sortOrder,
  }) async {
    final companion = IngredientsCompanion(id: Value(id));

    if (name != null) companion.copyWith(name: Value(name));
    if (amount != null) companion.copyWith(amount: Value(amount));
    if (sortOrder != null) companion.copyWith(sortOrder: Value(sortOrder));

    return await _database.update(_database.ingredients).replace(companion);
  }

  // 材料を削除
  Future<int> deleteIngredient(int id) async {
    return await (_database.delete(_database.ingredients)
          ..where((ingredient) => ingredient.id.equals(id)))
        .go();
  }

  // レシピの全材料を削除
  Future<int> deleteAllIngredientsForRecipe(int recipeId) async {
    return await (_database.delete(_database.ingredients)
          ..where((ingredient) => ingredient.recipeId.equals(recipeId)))
        .go();
  }

  // 材料候補を検索（材料マスターから）
  Future<List<IngredientMasterData>> searchIngredientMaster(String query) async {
    return await (_database.select(_database.ingredientMaster)
          ..where((master) => master.name.like('%$query%'))
          ..limit(10))
        .get();
  }

  // 全ての材料候補を取得
  Future<List<IngredientMasterData>> getAllIngredientMaster() async {
    return await _database.select(_database.ingredientMaster).get();
  }
}