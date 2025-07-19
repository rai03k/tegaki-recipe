import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../models/database.dart';
import '../repositories/recipe_book_repository.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  late final TegakiDatabase _database;
  late final RecipeBookRepository _repository;
  List<RecipeBook> _recipeBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _database = TegakiDatabase();
    _repository = RecipeBookRepository(_database);
    _loadRecipeBooks();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _database.close();
    super.dispose();
  }

  Future<void> _loadRecipeBooks() async {
    try {
      final books = await _repository.getAllRecipeBooks();
      setState(() {
        _recipeBooks = books;
        _isLoading = false;
      });

      // レシピ本がある場合のみPageControllerを初期化
      if (_recipeBooks.isNotEmpty) {
        _pageController = PageController(
          viewportFraction: 0.5,
          initialPage: 0,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('レシピ本読み込みエラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight / 3;

    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.grey[100],
      body: Stack(
        children: [
          // メインコンテンツ
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_recipeBooks.isEmpty)
            _buildEmptyState()
          else
            _buildRecipeBooksCarousel(cardHeight),

          // ランプUI
          Positioned(top: 40, right: 30, child: _buildLampWidget()),
          // 時計UI
          Positioned(top: 70, left: 40, child: _buildClockWidget()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/create-recipe-book');
        },
        backgroundColor:
            widget.isDarkMode ? Colors.grey[700] : Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const HugeIcon(
          icon: HugeIcons.strokeRoundedAdd01,
          color: Colors.white,
        ),
      ),
    );
  }

  // 空状態の表示
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedBook02,
            color: widget.isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
            size: 80.0,
          ),
          const SizedBox(height: 24),
          Text(
            'レシピ本がまだないよ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: widget.isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '右下のボタンから\nレシピ本を作ってみよう！',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // レシピ本カルーセルの表示
  Widget _buildRecipeBooksCarousel(double cardHeight) {
    return Center(
      child: SizedBox(
        height: cardHeight + 80,
        child: PageView.builder(
          controller: _pageController,
          itemCount: _recipeBooks.length,
          clipBehavior: Clip.none,
          itemBuilder: (context, index) {
            final recipeBook = _recipeBooks[index];

            return AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                final currentPage =
                    _pageController.position.haveDimensions
                        ? _pageController.page!
                        : _pageController.initialPage.toDouble();

                final difference = (currentPage - index).abs();
                final scale = (1 - (difference * 0.2)).clamp(0.8, 1.0);

                return Transform.scale(scale: scale, child: child);
              },
              child: _buildCarouselItem(context, recipeBook, cardHeight),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCarouselItem(
    BuildContext context,
    RecipeBook recipeBook,
    double cardHeight,
  ) {
    final cardWidth = cardHeight * (3 / 4);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: cardWidth,
          height: cardHeight,
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: widget.isDarkMode ? Colors.grey[800] : Colors.white,
            border: Border.all(
              color:
                  widget.isDarkMode ? Colors.grey[600]! : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color:
                    widget.isDarkMode
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child:
              recipeBook.coverImagePath != null
                  ? FutureBuilder<bool>(
                    future: File(recipeBook.coverImagePath!).exists(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data == true) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            File(recipeBook.coverImagePath!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultBookContent(recipeBook);
                            },
                          ),
                        );
                      } else {
                        return _buildDefaultBookContent(recipeBook);
                      }
                    },
                  )
                  : _buildDefaultBookContent(recipeBook),
        ),
        const SizedBox(height: 16),
        // タイトルを下部に表示（画像がある場合）
        if (recipeBook.coverImagePath != null)
          Text(
            recipeBook.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: widget.isDarkMode ? Colors.grey[300] : Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildLampWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 吊り下げ棒
        Container(
          width: 1,
          height: 60,
          color: widget.isDarkMode ? Colors.white70 : Colors.black54,
        ),
        // ランプ本体
        Stack(
          alignment: Alignment.center,
          children: [
            // ライトモード時の光エフェクト
            if (!widget.isDarkMode)
              Positioned(
                top: 50,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.yellow.withOpacity(0.6),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            // ランプ画像
            GestureDetector(
              onTap: widget.onThemeToggle,
              child: Container(
                height: 70,
                child: ColorFiltered(
                  colorFilter:
                      widget.isDarkMode
                          ? const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          )
                          : const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.multiply,
                          ),
                  child: Image.asset(
                    'assets/images/furniture/lamp.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // デフォルトの本コンテンツ（画像がない、または読み込めない場合）
  Widget _buildDefaultBookContent(RecipeBook recipeBook) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedBook02,
              color: widget.isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
              size: 48.0,
            ),
            const SizedBox(height: 8),
            Text(
              recipeBook.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: widget.isDarkMode ? Colors.grey[200] : Colors.grey[800],
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClockWidget() {
    return Container(
      height: 100,
      child: ColorFiltered(
        colorFilter:
            widget.isDarkMode
                ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                : const ColorFilter.mode(
                  Colors.transparent,
                  BlendMode.multiply,
                ),
        child: Image.asset(
          'assets/images/furniture/clock.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
