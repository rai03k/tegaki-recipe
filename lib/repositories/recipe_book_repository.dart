import 'package:drift/drift.dart';
import '../models/database.dart';

class RecipeBookRepository {
  final TegakiDatabase _database;

  RecipeBookRepository(this._database);

  // 全てのレシピ本を取得
  Future<List<RecipeBook>> getAllRecipeBooks() async {
    return await _database.select(_database.recipeBooks).get();
  }

  // IDでレシピ本を取得
  Future<RecipeBook?> getRecipeBookById(int id) async {
    return await (_database.select(_database.recipeBooks)
          ..where((book) => book.id.equals(id)))
        .getSingleOrNull();
  }

  // レシピ本を作成
  Future<int> createRecipeBook({
    required String title,
    String? coverImagePath,
  }) async {
    return await _database.into(_database.recipeBooks).insert(
          RecipeBooksCompanion(
            title: Value(title),
            coverImagePath: Value(coverImagePath),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  // レシピ本を更新
  Future<bool> updateRecipeBook({
    required int id,
    String? title,
    String? coverImagePath,
  }) async {
    var companion = RecipeBooksCompanion(
      id: Value(id),
      updatedAt: Value(DateTime.now()),
    );

    if (title != null) {
      companion = companion.copyWith(title: Value(title));
    }
    if (coverImagePath != null) {
      companion = companion.copyWith(coverImagePath: Value(coverImagePath));
    }

    return await _database.update(_database.recipeBooks).replace(companion);
  }

  // レシピ本を削除
  Future<int> deleteRecipeBook(int id) async {
    return await (_database.delete(_database.recipeBooks)
          ..where((book) => book.id.equals(id)))
        .go();
  }

  // レシピ本に含まれるレシピの数を取得
  Future<int> getRecipeCountInBook(int recipeBookId) async {
    final query = _database.selectOnly(_database.recipes)
      ..addColumns([_database.recipes.id.count()])
      ..where(_database.recipes.recipeBookId.equals(recipeBookId));

    final result = await query.getSingle();
    return result.read(_database.recipes.id.count()) ?? 0;
  }
}