import 'dart:io';
import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tegaki_recipe/view_models/recipe_view_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:turn_page_transition/turn_page_transition.dart';
import '../models/database.dart';
import '../services/image_service.dart';
import '../view_models/theme_view_model.dart';
import '../services/database_service.dart';

// レシピの材料を取得するプロバイダー
final recipeIngredientsProvider = FutureProvider.family
    .autoDispose<List<Ingredient>, int>((ref, recipeId) async {
      final database = DatabaseService.instance.database;
      final ingredients =
          await (database.select(database.ingredients)
                ..where((tbl) => tbl.recipeId.equals(recipeId))
                ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
              .get();
      return ingredients;
    });

// レシピ本の全レシピを取得するプロバイダー
final recipeBookRecipesProvider = FutureProvider.family
    .autoDispose<List<Recipe>, int>((ref, recipeBookId) async {
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
  int _currentIndex = 0;
  late TurnPageController _turnPageController;

  @override
  void initState() {
    super.initState();
    _turnPageController = TurnPageController();
  }

  @override
  void dispose() {
    _turnPageController.dispose();
    super.dispose();
  }

  // 画像が存在するかどうかを判定
  bool hasImage(Recipe recipe) =>
      recipe.imagePath != null && recipe.imagePath!.isNotEmpty;

  // AppBar、Body、Footerを含む完全なページレイアウト
  Widget _buildFullPageLayout(
    BuildContext context,
    bool isDarkMode,
    Recipe recipe,
    List<Recipe> recipes,
    bool isTablet,
    int currentPageIndex,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.white,
        // 紙の質感を表現するため、わずかな影を追加
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // AppBar部分
            _buildCustomAppBar(context, isDarkMode, recipe),

            // 区切り線
            Container(
              height: 1,
              color:
                  isDarkMode
                      ? Colors.grey[800]!.withValues(alpha: 0.3)
                      : Colors.grey[300]!.withValues(alpha: 0.5),
            ),

            // Body部分（メインコンテンツ）
            Expanded(
              child:
                  isTablet
                      ? _buildTabletLayout(context, isDarkMode, recipe)
                      : _buildPhoneLayout(context, isDarkMode, recipe),
            ),

            // Footer部分（ページインジケーター）
            if (recipes.length > 1) ...[
              Container(
                height: 1,
                color:
                    isDarkMode
                        ? Colors.grey[800]!.withValues(alpha: 0.3)
                        : Colors.grey[300]!.withValues(alpha: 0.5),
              ),
              _buildPageIndicator(isDarkMode, recipes, currentPageIndex),
            ],
          ],
        ),
      ),
    );
  }

  // カスタムAppBar
  Widget _buildCustomAppBar(
    BuildContext context,
    bool isDarkMode,
    Recipe recipe,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedEdit02,
              color: isDarkMode ? Colors.white : Colors.black,
              size: 24.0,
            ),
            onPressed: () => _navigateToEditScreen(context, recipe),
          ),
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedDelete02,
              color: isDarkMode ? Colors.white : Colors.black,
              size: 24.0,
            ),
            onPressed: () => _showDeleteConfirmDialog(context, recipe),
          ),
        ],
      ),
    );
  }

  // ページインジケーター
  Widget _buildPageIndicator(bool isDarkMode, List<Recipe> recipes, int currentPageIndex) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        '${currentPageIndex + 1}/${recipes.length}',
        style: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black54,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

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

        // 初期インデックスを設定（一度だけ）
        if (_currentIndex == 0 && currentIndex != -1) {
          _currentIndex = currentIndex;
          // ウィジェット構築後に指定のページに移動
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (currentIndex > 0) {
              _turnPageController.animateToPage(currentIndex);
            }
          });
        }

        return Scaffold(
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          body: TurnPageView.builder(
            controller: _turnPageController,
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return _buildFullPageLayout(
                context,
                isDarkMode,
                recipe,
                recipes,
                isTablet,
                index, // 現在のページインデックスを渡す
              );
            },
            overleafColorBuilder: (index) {
              return isDarkMode
                  ? Colors.black.withOpacity(0.8)
                  : Colors.white.withOpacity(0.8);
            },
            overleafBorderWidthBuilder: (index) {
              return 0.5;
            },
            animationTransitionPoint: 0.5,
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
            ],

            const SizedBox(height: 20),

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
              ? FutureBuilder<File>(
                future: ImageService.getImageFile(recipe.imagePath!),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return FutureBuilder<bool>(
                      future: snapshot.data!.exists(),
                      builder: (context, existsSnapshot) {
                        print(
                          'DEBUG: Recipe image filename: ${recipe.imagePath}',
                        );
                        print(
                          'DEBUG: Recipe file path: ${snapshot.data!.path}',
                        );
                        print(
                          'DEBUG: Recipe file exists: ${existsSnapshot.data}',
                        );

                        if (existsSnapshot.hasData &&
                            existsSnapshot.data == true) {
                          print(
                            'DEBUG: Loading recipe image from: ${snapshot.data!.path}',
                          );
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('DEBUG: Recipe image load error: $error');
                                return _buildImagePlaceholder();
                              },
                            ),
                          );
                        }
                        print(
                          'DEBUG: Recipe file does not exist, showing placeholder',
                        );
                        return _buildImagePlaceholder();
                      },
                    );
                  }
                  return _buildImagePlaceholder();
                },
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
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9BB8D3), // 青い背景色
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '材料（1人分）',
                      style: TextStyle(
                        fontSize: 24,
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
                                Flexible(
                                  child: Text(
                                    '${ingredient.name}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color:
                                          isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                ),
                                if (ingredient.amount != null ||
                                    ingredient.amount!.isEmpty) ...[
                                  Text(
                                    '・・・',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color:
                                          isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                      letterSpacing: -3,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${ingredient.amount ?? ''}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color:
                                            isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
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
                style: TextStyle(fontSize: 16, color: Colors.red),
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
          padding: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF9BB8D3), // 青い背景色
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '作り方',
            style: TextStyle(
              fontSize: 24,
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

  void _navigateToEditScreen(BuildContext context, Recipe recipe) async {
    final result = await context.pushNamed(
      'edit-recipe',
      pathParameters: {'recipeId': recipe.id.toString()},
      extra: recipe,
    );

    // 編集完了後にプロバイダーを無効化してデータを再取得
    if (result == true && mounted) {
      // プロバイダーを無効化して最新データを取得
      ref.invalidate(recipeBookRecipesProvider(recipe.recipeBookId));
      ref.invalidate(recipeIngredientsProvider(recipe.id));

      // 少し待ってから再構築を促す
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          ref.refresh(recipeBookRecipesProvider(recipe.recipeBookId));
        }
      });
    }
  }

  void _showDeleteConfirmDialog(BuildContext context, Recipe recipe) {
    final isDarkMode = ref.read(themeNotifierProvider) == ThemeMode.dark;

    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
          title: Text(
            'レシピを削除しますか？',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '「${recipe.title}」を削除します。\nこの操作は取り消せません。',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'キャンセル',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                '削除',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        _deleteRecipe(context, recipe);
      }
    });
  }

  void _deleteRecipe(BuildContext context, Recipe recipe) async {
    final success = await ref
        .read(recipeNotifierProvider.notifier)
        .deleteRecipe(recipe.id, recipe.recipeBookId);

    if (success && mounted) {
      // 削除成功時は目次画面に戻る
      context.pop();
    }
  }
}
