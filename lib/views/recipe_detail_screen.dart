import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/database.dart';
import '../view_models/theme_view_model.dart';
import '../services/database_service.dart';

// レシピの材料を取得するプロバイダー
final recipeIngredientsProvider = FutureProvider.family<List<Ingredient>, int>((
  ref,
  recipeId,
) async {
  final database = DatabaseService.instance.database;
  final ingredients =
      await (database.select(database.ingredients)
            ..where((tbl) => tbl.recipeId.equals(recipeId))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
          .get();
  return ingredients;
});

// レシピ本の全レシピを取得するプロバイダー
final recipeBookRecipesProvider = FutureProvider.family<List<Recipe>, int>((
  ref,
  recipeBookId,
) async {
  final database = DatabaseService.instance.database;
  final recipes =
      await (database.select(database.recipes)
            ..where((tbl) => tbl.recipeBookId.equals(recipeBookId))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.id)]))
          .get();
  return recipes;
});

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  PageController? _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  // 画像が存在するかどうかを判定
  bool hasImage(Recipe recipe) =>
      recipe.imagePath != null && recipe.imagePath!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeNotifierProvider) == ThemeMode.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // レシピ本の全レシピを取得
    final recipesAsync = ref.watch(
      recipeBookRecipesProvider(widget.recipe.recipeBookId),
    );

    return recipesAsync.when(
      data: (recipes) {
        // 現在のレシピの索引を取得
        final currentIndex = recipes.indexWhere(
          (r) => r.id == widget.recipe.id,
        );

        // PageControllerを初期化（一度だけ）
        if (_pageController == null && currentIndex != -1) {
          _pageController = PageController(initialPage: currentIndex);
          _currentIndex = currentIndex;
        }

        return Scaffold(
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // PageViewでレシピをスライド表示（画面の大部分）
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: recipes.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return isTablet
                          ? _buildTabletLayout(context, isDarkMode, recipe)
                          : _buildPhoneLayout(context, isDarkMode, recipe);
                    },
                  ),
                ),

                // ページインジケーター（画面最下部）
                if (recipes.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      '${_currentIndex + 1}/${recipes.length}',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      loading:
          () => Scaffold(
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
            body: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (error, stack) => Scaffold(
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
            body: SafeArea(
              child:
                  isTablet
                      ? _buildTabletLayout(context, isDarkMode, widget.recipe)
                      : _buildPhoneLayout(context, isDarkMode, widget.recipe),
            ),
          ),
    );
  }

  // スマホ（縦1カラム）レイアウト
  Widget _buildPhoneLayout(
    BuildContext context,
    bool isDarkMode,
    Recipe recipe,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 戻るボタン
            _buildBackButton(context, isDarkMode),

            const SizedBox(height: 20),

            // 料理画像（画像がある場合のみ表示）
            if (hasImage(recipe)) ...[
              _buildRecipeImage(recipe),
              const SizedBox(height: 20),
            ],

            // 料理名
            _buildRecipeTitle(isDarkMode, recipe),

            // 所要時間
            if ((recipe.cookingTimeMinutes ?? 0) > 0) ...[
              const SizedBox(height: 4),
              _buildCookingTime(isDarkMode, recipe),
              const SizedBox(height: 8),
            ],

            // メモ
            if (recipe.memo != null && recipe.memo!.isNotEmpty) ...[
              _buildMemo(isDarkMode, recipe),
              const SizedBox(height: 20),
            ],

            const SizedBox(height: 8),

            // 材料
            _buildIngredientsSection(isDarkMode, recipe),

            const SizedBox(height: 20),

            // 作り方
            _buildInstructionsSection(isDarkMode, recipe),

            const SizedBox(height: 20),

            // 参考URL
            if (recipe.referenceUrl != null &&
                recipe.referenceUrl!.isNotEmpty) ...[
              Text(
                '参考URL',
                style: TextStyle(
                  fontSize: 20,
                  color: isDarkMode ? Colors.white : Colors.black,
                  decoration: TextDecoration.underline,
                ),
              ),
              _buildReferenceUrl(isDarkMode, recipe),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  // タブレット（横2カラム）レイアウト
  Widget _buildTabletLayout(
    BuildContext context,
    bool isDarkMode,
    Recipe recipe,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // 戻るボタン
          Row(children: [_buildBackButton(context, isDarkMode)]),

          const SizedBox(height: 20),

          // タイトルと所要時間
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecipeTitle(isDarkMode, recipe),
              const SizedBox(height: 10),
              _buildCookingTime(isDarkMode, recipe),
              if (recipe.memo != null && recipe.memo!.isNotEmpty) ...[
                const SizedBox(height: 15),
                _buildMemo(isDarkMode, recipe),
              ],
            ],
          ),

          const SizedBox(height: 20),

          // 2カラムレイアウト
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左カラム: 画像・作り方・参考URL（2/3幅）
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 画像（画像がある場合のみ表示）
                      if (hasImage(recipe)) ...[
                        _buildRecipeImage(recipe),
                        const SizedBox(height: 20),
                      ],

                      // 作り方
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInstructionsSection(isDarkMode, recipe),
                              if (recipe.referenceUrl != null &&
                                  recipe.referenceUrl!.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                _buildReferenceUrl(isDarkMode, recipe),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 30),

                // 右カラム: 材料（1/3幅）
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: _buildIngredientsSection(isDarkMode, recipe),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDarkMode) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white24 : Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedArrowLeft01,
          color: isDarkMode ? Colors.white : Colors.black,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildRecipeImage(Recipe recipe) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child:
          (recipe.imagePath != null && recipe.imagePath!.isNotEmpty)
              ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  recipe.imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImagePlaceholder();
                  },
                ),
              )
              : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: Center(
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedImage01,
          color: Colors.grey[500]!,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildRecipeTitle(bool isDarkMode, Recipe recipe) {
    return Text(
      recipe.title,
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : Colors.black,
        height: 1.0,
        letterSpacing: -1.0,
      ),
    );
  }

  Widget _buildCookingTime(bool isDarkMode, Recipe recipe) {
    return Row(
      children: [
        HugeIcon(
          icon: HugeIcons.strokeRoundedTimer01,
          color: isDarkMode ? Colors.white70 : Colors.black54,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          '${recipe.cookingTimeMinutes ?? 0}分',
          style: TextStyle(
            fontSize: 20,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildMemo(bool isDarkMode, Recipe recipe) {
    return Text(
      recipe.memo ?? '',
      style: TextStyle(
        fontSize: 20,
        color: isDarkMode ? Colors.white60 : Colors.black45,
      ),
    );
  }

  Widget _buildIngredientsSection(bool isDarkMode, Recipe recipe) {
    return Consumer(
      builder: (context, ref, child) {
        final ingredientsAsync = ref.watch(
          recipeIngredientsProvider(recipe.id),
        );

        return ingredientsAsync.when(
          data:
              (ingredients) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9BB8D3), // 青い背景色
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '材料（1人分）',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 材料リスト
                  if (ingredients.isEmpty)
                    Text(
                      '材料が登録されていません',
                      style: TextStyle(
                        fontSize: 20,
                        color: isDarkMode ? Colors.white60 : Colors.black45,
                      ),
                    )
                  else
                    ...ingredients
                        .map(
                          (ingredient) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Text(
                                  '• ',
                                  style: TextStyle(
                                    fontFamily: 'ArmedLemon',
                                    fontSize: 16,
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${ingredient.name}　${ingredient.amount ?? ''}',
                                    style: TextStyle(
                                      fontFamily: 'ArmedLemon',
                                      fontSize: 16,
                                      color:
                                          isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                ],
              ),
          loading: () => const CircularProgressIndicator(),
          error:
              (error, stack) => Text(
                '材料の読み込みエラー',
                style: TextStyle(
                  fontFamily: 'ArmedLemon',
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
        );
      },
    );
  }

  Widget _buildInstructionsSection(bool isDarkMode, Recipe recipe) {
    final instructions = (recipe.instructions ?? '').split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF9BB8D3), // 青い背景色
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '作り方',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 作り方リスト
        ...instructions.asMap().entries.map((entry) {
          final index = entry.key;
          final instruction = entry.value.trim();

          if (instruction.isEmpty) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Expanded(
                  child: Text(
                    instruction,
                    style: TextStyle(
                      fontSize: 20,
                      color: isDarkMode ? Colors.white : Colors.black,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildReferenceUrl(bool isDarkMode, Recipe recipe) {
    return GestureDetector(
      onTap: () => _launchUrl(recipe.referenceUrl ?? ''),
      child: Text(
        recipe.referenceUrl ?? '',
        style: TextStyle(fontSize: 20, color: Colors.blue),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
