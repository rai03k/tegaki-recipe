import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../models/database.dart';
import '../view_models/recipe_view_model.dart';
import '../view_models/theme_view_model.dart';
import 'dart:io';

class TableOfContentsScreen extends ConsumerStatefulWidget {
  final RecipeBook recipeBook;

  const TableOfContentsScreen({super.key, required this.recipeBook});

  @override
  ConsumerState<TableOfContentsScreen> createState() =>
      _TableOfContentsScreenState();
}

class _TableOfContentsScreenState extends ConsumerState<TableOfContentsScreen> {
  @override
  void initState() {
    super.initState();
    // 画面初期化時にレシピ一覧を読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(recipeNotifierProvider.notifier)
          .loadRecipesByBookId(widget.recipeBook.id);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 画面に戻ってきた時にデータを再読み込み（非同期で実行）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recipeNotifierProvider.notifier).refresh(widget.recipeBook.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeNotifierProvider) == ThemeMode.dark;
    final recipeState = ref.watch(recipeNotifierProvider);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 戻るボタンとレシピ本情報
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
                        // レシピ本の小さな表紙画像
                        if (widget.recipeBook.coverImagePath != null)
                          FutureBuilder<bool>(
                            future:
                                File(
                                  widget.recipeBook.coverImagePath!,
                                ).exists(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data == true) {
                                return Container(
                                  width: 40,
                                  height: 53, // 3:4比率
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
                                      File(widget.recipeBook.coverImagePath!),
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
                            widget.recipeBook.title,
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
                ],
              ),
              const SizedBox(height: 32),

              // 目次タイトル
              Text(
                '目次',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // サブタイトル
              Text(
                '料理名をタップでそのレシピに移動できるよ',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // レシピ一覧またはローディング・空状態
              Expanded(
                child:
                    recipeState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : recipeState.recipes.isEmpty
                        ? _buildEmptyState(isDarkMode)
                        : _buildRecipeList(isDarkMode, recipeState.recipes),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push(
            '/create-recipe/${widget.recipeBook.id}',
            extra: widget.recipeBook,
          );
          // レシピ作成画面から戻ってきたときにデータを再読み込み
          ref.read(recipeNotifierProvider.notifier).refresh(widget.recipeBook.id);
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
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // レシピ一覧の表示
  Widget _buildRecipeList(bool isDarkMode, List<Recipe> recipes) {
    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        final pageNumber = index + 1; // ページ番号は1から開始

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: GestureDetector(
            onTap: () {
              context.push('/recipe-detail/${recipe.id}', extra: recipe);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                ),
              ),
              child: _buildTableOfContentsRow(
                recipe.title,
                pageNumber,
                isDarkMode,
              ),
            ),
          ),
        );
      },
    );
  }

  // 目次行の構築（・料理名.......ページ数）
  Widget _buildTableOfContentsRow(
    String recipeName,
    int pageNumber,
    bool isDarkMode,
  ) {
    return Row(
      children: [
        // ・マーク
        Text(
          '・',
          style: TextStyle(
            fontSize: 18,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(width: 8),

        // 料理名
        Expanded(
          child: Text(
            recipeName,
            style: TextStyle(
              fontSize: 18,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // ドットリーダー（.......）
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: CustomPaint(
              painter: DotLeaderPainter(
                color: isDarkMode ? Colors.grey[500]! : Colors.grey[400]!,
              ),
              child: const SizedBox(height: 20),
            ),
          ),
        ),

        // ページ数
        Text(
          pageNumber.toString(),
          style: TextStyle(
            fontSize: 18,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
      ],
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
