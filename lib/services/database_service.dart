import '../models/database.dart';
import '../repositories/recipe_book_repository.dart';
import '../repositories/recipe_repository.dart';
import '../repositories/ingredient_repository.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static TegakiDatabase? _database;

  // プライベートコンストラクタ
  DatabaseService._();

  // シングルトンインスタンス取得
  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  // データベース取得（遅延初期化）
  TegakiDatabase get database {
    _database ??= TegakiDatabase();
    return _database!;
  }

  // Repository取得メソッド
  RecipeBookRepository get recipeBookRepository {
    return RecipeBookRepository(database);
  }

  RecipeRepository get recipeRepository {
    return RecipeRepository(database);
  }

  IngredientRepository get ingredientRepository {
    return IngredientRepository(database);
  }

  // データベースを閉じる（アプリ終了時など）
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  // データベースをリセット（テスト用など）
  Future<void> reset() async {
    await close();
    _database = null;
  }
}