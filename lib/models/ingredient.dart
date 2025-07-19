import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'ingredient.freezed.dart';

/// 材料の定義クラス
@freezed
class Ingredient with _$Ingredient {
  const factory Ingredient({
    required String name,
    required String iconPath,
    required Color backgroundColor,
    String? category,
  }) = _Ingredient;
}

/// レシピで使用する材料（分量付き）
@freezed
class RecipeIngredient with _$RecipeIngredient {
  const factory RecipeIngredient({
    required String name,
    required String amount,
    String? iconPath,
    Color? backgroundColor,
  }) = _RecipeIngredient;
}

/// 材料の定数データ
class IngredientData {
  static const List<Ingredient> predefinedIngredients = [
    // 野菜類
    Ingredient(
      name: '玉ねぎ',
      iconPath: 'assets/images/ingredients/tamanegi.png',
      backgroundColor: Color(0xFFFFE4E1),
      category: '野菜',
    ),
    Ingredient(
      name: 'にんじん',
      iconPath: 'assets/images/ingredients/ninzin.png',
      backgroundColor: Color(0xFFFFE4B5),
      category: '野菜',
    ),
    Ingredient(
      name: 'じゃがいも',
      iconPath: 'assets/images/ingredients/jagaimo.png',
      backgroundColor: Color(0xFFF5F5DC),
      category: '野菜',
    ),
    Ingredient(
      name: 'キャベツ',
      iconPath: 'assets/images/ingredients/kyabetu.png',
      backgroundColor: Color(0xFFE0FFE0),
      category: '野菜',
    ),
    Ingredient(
      name: 'レタス',
      iconPath: 'assets/images/ingredients/retasu.png',
      backgroundColor: Color(0xFFE0FFE0),
      category: '野菜',
    ),
    Ingredient(
      name: 'トマト',
      iconPath: 'assets/images/ingredients/tomato.png',
      backgroundColor: Color(0xFFFFE4E1),
      category: '野菜',
    ),
    Ingredient(
      name: '大根',
      iconPath: 'assets/images/ingredients/daikon.png',
      backgroundColor: Color(0xFFF5F5F5),
      category: '野菜',
    ),
    Ingredient(
      name: 'かぶ',
      iconPath: 'assets/images/ingredients/kabu.png',
      backgroundColor: Color(0xFFF5F5F5),
      category: '野菜',
    ),
    Ingredient(
      name: 'なす',
      iconPath: 'assets/images/ingredients/nasu.png',
      backgroundColor: Color(0xFFE6E6FA),
      category: '野菜',
    ),
    Ingredient(
      name: 'ねぎ',
      iconPath: 'assets/images/ingredients/negi.png',
      backgroundColor: Color(0xFFE0FFE0),
      category: '野菜',
    ),
    Ingredient(
      name: 'さつまいも',
      iconPath: 'assets/images/ingredients/satumaimo.png',
      backgroundColor: Color(0xFFFFE4B5),
      category: '野菜',
    ),
    Ingredient(
      name: 'しいたけ',
      iconPath: 'assets/images/ingredients/siitake.png',
      backgroundColor: Color(0xFFF5DEB3),
      category: '野菜',
    ),
    
    // 肉類
    Ingredient(
      name: '牛肉',
      iconPath: 'assets/icons/ingredients/beef.png',
      backgroundColor: Color(0xFFFFE4E4),
      category: '肉類',
    ),
    Ingredient(
      name: '豚肉',
      iconPath: 'assets/icons/ingredients/pork.png',
      backgroundColor: Color(0xFFFFE4E4),
      category: '肉類',
    ),
    Ingredient(
      name: '鶏肉',
      iconPath: 'assets/icons/ingredients/chicken.png',
      backgroundColor: Color(0xFFFFE4E4),
      category: '肉類',
    ),
    Ingredient(
      name: 'ひき肉',
      iconPath: 'assets/icons/ingredients/ground_meat.png',
      backgroundColor: Color(0xFFFFE4E4),
      category: '肉類',
    ),
    
    // 魚類
    Ingredient(
      name: 'さけ',
      iconPath: 'assets/icons/ingredients/salmon.png',
      backgroundColor: Color(0xFFFFE4D6),
      category: '魚類',
    ),
    Ingredient(
      name: 'まぐろ',
      iconPath: 'assets/icons/ingredients/tuna.png',
      backgroundColor: Color(0xFFFFE4D6),
      category: '魚類',
    ),
    Ingredient(
      name: 'いわし',
      iconPath: 'assets/icons/ingredients/sardine.png',
      backgroundColor: Color(0xFFFFE4D6),
      category: '魚類',
    ),
    
    // 調味料
    Ingredient(
      name: '塩',
      iconPath: 'assets/icons/ingredients/salt.png',
      backgroundColor: Color(0xFFF0F0F0),
      category: '調味料',
    ),
    Ingredient(
      name: 'こしょう',
      iconPath: 'assets/icons/ingredients/pepper.png',
      backgroundColor: Color(0xFFF0F0F0),
      category: '調味料',
    ),
    Ingredient(
      name: '醤油',
      iconPath: 'assets/icons/ingredients/soy_sauce.png',
      backgroundColor: Color(0xFFE8E8E8),
      category: '調味料',
    ),
    Ingredient(
      name: 'みそ',
      iconPath: 'assets/icons/ingredients/miso.png',
      backgroundColor: Color(0xFFE8E8E8),
      category: '調味料',
    ),
    Ingredient(
      name: '砂糖',
      iconPath: 'assets/icons/ingredients/sugar.png',
      backgroundColor: Color(0xFFF0F0F0),
      category: '調味料',
    ),
    Ingredient(
      name: '酢',
      iconPath: 'assets/icons/ingredients/vinegar.png',
      backgroundColor: Color(0xFFF0F0F0),
      category: '調味料',
    ),
    Ingredient(
      name: '油',
      iconPath: 'assets/icons/ingredients/oil.png',
      backgroundColor: Color(0xFFFFE4B5),
      category: '調味料',
    ),
    
    // その他
    Ingredient(
      name: '米',
      iconPath: 'assets/icons/ingredients/rice.png',
      backgroundColor: Color(0xFFF5F5DC),
      category: 'その他',
    ),
    Ingredient(
      name: 'パン',
      iconPath: 'assets/icons/ingredients/bread.png',
      backgroundColor: Color(0xFFFFE4B5),
      category: 'その他',
    ),
    Ingredient(
      name: '卵',
      iconPath: 'assets/icons/ingredients/egg.png',
      backgroundColor: Color(0xFFFFE4B5),
      category: 'その他',
    ),
    Ingredient(
      name: '牛乳',
      iconPath: 'assets/icons/ingredients/milk.png',
      backgroundColor: Color(0xFFF0F0F0),
      category: 'その他',
    ),
  ];

  /// 名前で材料を検索
  static List<Ingredient> searchByName(String query) {
    if (query.isEmpty) return [];
    
    return predefinedIngredients
        .where((ingredient) => ingredient.name.contains(query))
        .toList();
  }

  /// カテゴリで材料を検索
  static List<Ingredient> getByCategory(String category) {
    return predefinedIngredients
        .where((ingredient) => ingredient.category == category)
        .toList();
  }

  /// すべてのカテゴリを取得
  static List<String> getAllCategories() {
    return predefinedIngredients
        .map((ingredient) => ingredient.category ?? 'その他')
        .toSet()
        .toList();
  }
}