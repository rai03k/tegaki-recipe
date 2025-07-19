import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// レシピ本テーブル
class RecipeBooks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get coverImagePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// レシピテーブル
class Recipes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recipeBookId =>
      integer().references(RecipeBooks, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get imagePath => text().nullable()();
  IntColumn get cookingTimeMinutes => integer().nullable()();
  TextColumn get memo => text().nullable()();
  TextColumn get instructions => text().nullable()();
  TextColumn get referenceUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// 材料テーブル
class Ingredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recipeId =>
      integer().references(Recipes, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get amount => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

// 材料マスターテーブル（予測候補用）
class IngredientMaster extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get iconPath => text().nullable()();
  TextColumn get backgroundColor => text().nullable()(); // HEXカラーコード
}

@DriftDatabase(tables: [RecipeBooks, Recipes, Ingredients, IngredientMaster])
class TegakiDatabase extends _$TegakiDatabase {
  TegakiDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      // 初期データの追加
      await _insertInitialIngredients();
    },
  );

  // 初期材料データを追加
  Future<void> _insertInitialIngredients() async {
    final ingredients = [
      {'name': '玉ねぎ', 'iconPath': null, 'backgroundColor': '#FFF3E0'},
      {'name': 'にんじん', 'iconPath': null, 'backgroundColor': '#FF8A65'},
      {'name': 'じゃがいも', 'iconPath': null, 'backgroundColor': '#FFCC80'},
      {'name': '豚肉', 'iconPath': null, 'backgroundColor': '#FFCDD2'},
      {'name': '鶏肉', 'iconPath': null, 'backgroundColor': '#F8BBD9'},
      {'name': '牛肉', 'iconPath': null, 'backgroundColor': '#FFCCCB'},
      {'name': '米', 'iconPath': null, 'backgroundColor': '#F5F5F5'},
      {'name': '塩', 'iconPath': null, 'backgroundColor': '#FFFFFF'},
      {'name': '醤油', 'iconPath': null, 'backgroundColor': '#8D6E63'},
      {'name': 'みそ', 'iconPath': null, 'backgroundColor': '#D7CCC8'},
    ];

    for (final ingredient in ingredients) {
      await into(ingredientMaster).insert(
        IngredientMasterCompanion(
          name: Value(ingredient['name'] as String),
          iconPath: Value(ingredient['iconPath'] as String?),
          backgroundColor: Value(ingredient['backgroundColor'] as String?),
        ),
      );
    }
  }
}

// データベースコネクション設定
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tegaki_recipe.db'));
    return driftDatabase(name: 'tegaki_recipe');
  });
}
