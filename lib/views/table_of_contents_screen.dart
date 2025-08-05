import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../models/database.dart';
import '../services/image_service.dart';
import '../view_models/recipe_view_model.dart';
import '../view_models/recipe_book_view_model.dart';
import '../view_models/theme_view_model.dart';
import 'dart:io';
import 'dart:math' as math;

class TableOfContentsScreen extends ConsumerStatefulWidget {
  final RecipeBook recipeBook;

  const TableOfContentsScreen({super.key, required this.recipeBook});

  @override
  ConsumerState<TableOfContentsScreen> createState() =>
      _TableOfContentsScreenState();
}

class _TableOfContentsScreenState extends ConsumerState<TableOfContentsScreen> {
  late RecipeBook _currentRecipeBook;

  @override
  void initState() {
    super.initState();
    _currentRecipeBook = widget.recipeBook;
    // 画面初期化時にレシピ一覧を読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(recipeNotifierProvider.notifier)
          .loadRecipesByBookId(_currentRecipeBook.id);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 画面に戻ってきた時にデータを再読み込み（非同期で実行）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recipeNotifierProvider.notifier).refresh(_currentRecipeBook.id);
    });
  }

  // RecipeBookの最新データを取得して画面を更新
  Future<void> _refreshRecipeBookData() async {
    final updatedRecipeBook = await ref
        .read(recipeBookNotifierProvider.notifier)
        .getRecipeBookById(_currentRecipeBook.id);

    if (updatedRecipeBook != null && mounted) {
      setState(() {
        _currentRecipeBook = updatedRecipeBook;
      });
      // レシピ本一覧も再読み込み
      ref.read(recipeBookNotifierProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeNotifierProvider) == ThemeMode.dark;
    final recipeState = ref.watch(recipeNotifierProvider);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 戻るボタンとレシピ本情報、編集ボタン
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        color: isDarkMode ? Colors.white : Colors.black,
                        size: 24.0,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        children: [
                          if (_currentRecipeBook.coverImagePath != null)
                            FutureBuilder<bool>(
                              future:
                                  File(
                                    _currentRecipeBook.coverImagePath!,
                                  ).exists(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data == true) {
                                  return Container(
                                    width: 40,
                                    height: 53,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color:
                                            isDarkMode
                                                ? Colors.grey[600]!
                                                : Colors.grey[300]!,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: Image.file(
                                        File(
                                          _currentRecipeBook.coverImagePath!,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container(
                                    width: 40,
                                    height: 53,
                                    decoration: BoxDecoration(
                                      color:
                                          isDarkMode
                                              ? Colors.grey[800]
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color:
                                            isDarkMode
                                                ? Colors.grey[600]!
                                                : Colors.grey[300]!,
                                      ),
                                    ),
                                    child: HugeIcon(
                                      icon: HugeIcons.strokeRoundedBook02,
                                      color:
                                          isDarkMode
                                              ? Colors.grey[400]!
                                              : Colors.grey[600]!,
                                      size: 20.0,
                                    ),
                                  );
                                }
                              },
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _currentRecipeBook.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await context.push(
                          '/edit-recipe-book/${_currentRecipeBook.id}',
                          extra: _currentRecipeBook,
                        );
                        await _refreshRecipeBookData();
                      },
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedEdit02,
                        color: isDarkMode ? Colors.white : Colors.black,
                        size: 24.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // 目次タイトル
                Text(
                  '目次',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 8),
                // サブタイトル
                Text(
                  '料理名をタップでそのレシピに移動できるよ',
                  style: TextStyle(
                    fontSize: 18,
                    letterSpacing: -1.5,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                // レシピ一覧またはローディング・空状態
                if (recipeState.isLoading)
                  const Center(child: CircularProgressIndicator()),
                if (!recipeState.isLoading && recipeState.recipes.isEmpty)
                  _buildEmptyState(isDarkMode),
                if (!recipeState.isLoading && recipeState.recipes.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                      ),
                    ),
                    child: Column(
                      children: List.generate(recipeState.recipes.length, (
                        index,
                      ) {
                        final recipe = recipeState.recipes[index];
                        final pageNumber = index + 1;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 8.0,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              context.push(
                                '/recipe-detail/${recipe.id}',
                                extra: recipe,
                              );
                            },
                            child: _buildTableOfContentsRow(
                              recipe.title,
                              pageNumber,
                              isDarkMode,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push(
            '/create-recipe/${_currentRecipeBook.id}',
            extra: _currentRecipeBook,
          );
          ref
              .read(recipeNotifierProvider.notifier)
              .refresh(_currentRecipeBook.id);
        },
        backgroundColor: isDarkMode ? Colors.grey[700] : Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const HugeIcon(
          icon: HugeIcons.strokeRoundedAdd01,
          color: Colors.white,
        ),
      ),
    );
  }

  // 空状態の表示
  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'レシピがまだありません',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '右下のボタンから\n最初のレシピを作ってみよう！',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              height: 1.5,
              letterSpacing: -1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 目次行の構築（・料理名.......ページ数）
  Widget _buildTableOfContentsRow(
    String recipeName,
    int pageNumber,
    bool isDarkMode,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textStyle = TextStyle(
          fontSize: 18,
          color: isDarkMode ? Colors.white : Colors.black,
          letterSpacing: -1.5,
        );

        final pageStyle = TextStyle(
          fontSize: 20,
          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
        );

        // 料理名の実際の幅を計算
        final recipeTextPainter = TextPainter(
          text: TextSpan(text: recipeName, style: textStyle),
          textDirection: TextDirection.ltr,
        );
        recipeTextPainter.layout();

        // ページ数の実際の幅を計算
        final pageTextPainter = TextPainter(
          text: TextSpan(text: pageNumber.toString(), style: pageStyle),
          textDirection: TextDirection.ltr,
        );
        pageTextPainter.layout();

        final availableWidth = constraints.maxWidth;
        final margin = 16.0; // 左右のマージン

        // 料理名が長すぎる場合は省略
        final maxRecipeWidth =
            availableWidth -
            pageTextPainter.width -
            margin -
            10; // 60はドットのための最小幅
        final actualRecipeWidth = math.min(
          recipeTextPainter.width,
          maxRecipeWidth,
        );

        return SizedBox(
          height: 24,
          child: Stack(
            children: [
              // 料理名（左端）
              Positioned(
                left: 0,
                top: 2,
                child: SizedBox(
                  width: actualRecipeWidth,
                  child: Text(recipeName, style: textStyle, maxLines: 1),
                ),
              ),

              // ドットリーダー（中央）
              Positioned(
                left: actualRecipeWidth + 4,
                right: pageTextPainter.width + 2,
                top: 4,
                child: CustomPaint(
                  painter: DotLeaderPainter(
                    color: isDarkMode ? Colors.grey[500]! : Colors.grey[400]!,
                  ),
                  child: const SizedBox(height: 20),
                ),
              ),

              // ページ数（右端固定）
              Positioned(
                right: 0,
                top: 2,
                child: Text(pageNumber.toString(), style: pageStyle),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ドットリーダー（.......）を描画するCustomPainter
class DotLeaderPainter extends CustomPainter {
  final Color color;

  DotLeaderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1.0;

    const dotSpacing = 8.0;
    final dotCount = (size.width / dotSpacing).floor();
    final y = size.height / 2;

    for (int i = 0; i < dotCount; i++) {
      final x = i * dotSpacing;
      canvas.drawCircle(Offset(x, y), 1.0, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
