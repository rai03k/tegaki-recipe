import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../models/database.dart';
import '../view_models/recipe_book_view_model.dart';
import '../view_models/theme_view_model.dart';
import '../constants/app_strings.dart';
import '../constants/ui_constants.dart';
import 'dart:io';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  PageController? _pageController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 画面に戻ってきた時にデータを再読み込み
    ref.read(recipeBookNotifierProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * UIConstants.cardHeightRatio;
    final recipeBookState = ref.watch(recipeBookNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    final isDarkMode = ref.watch(themeNotifierProvider) == ThemeMode.dark;

    // PageControllerの初期化
    if (recipeBookState.recipeBooks.isNotEmpty && _pageController == null) {
      _pageController = PageController(
        viewportFraction: UIConstants.carouselViewportFraction,
        initialPage: 0,
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? Color(ColorConstants.grey900) : Color(ColorConstants.grey100),
      body: Stack(
        children: [
          // メインコンテンツ
          if (recipeBookState.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (recipeBookState.recipeBooks.isEmpty)
            _buildEmptyState(isDarkMode)
          else
            _buildRecipeBooksCarousel(cardHeight, isDarkMode, recipeBookState.recipeBooks),

          // ランプUI
          Positioned(
            top: UIConstants.lampTopPosition,
            right: UIConstants.lampRightPosition,
            child: _buildLampWidget(isDarkMode, themeNotifier.toggleTheme),
          ),
          // 時計UI
          Positioned(
            top: UIConstants.clockTopPosition,
            left: UIConstants.clockLeftPosition,
            child: _buildClockWidget(isDarkMode),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/create-recipe-book');
          // 画面から戻ってきたときにデータを再読み込み
          ref.read(recipeBookNotifierProvider.notifier).refresh();
        },
        backgroundColor: isDarkMode ? Color(ColorConstants.grey700) : Colors.deepPurple,
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
          HugeIcon(
            icon: HugeIcons.strokeRoundedBook02,
            color: isDarkMode ? Color(ColorConstants.grey400) : Color(ColorConstants.grey600),
            size: UIConstants.iconSizeLarge,
          ),
          const SizedBox(height: UIConstants.paddingLarge),
          Text(
            AppStrings.noRecipeBooksYet,
            style: TextStyle(
              fontSize: UIConstants.fontSizeXLarge,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Color(ColorConstants.grey300) : Color(ColorConstants.grey700),
            ),
          ),
          const SizedBox(height: UIConstants.paddingMedium),
          Text(
            AppStrings.createRecipeBookGuide,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: UIConstants.fontSizeMedium,
              color: isDarkMode ? Color(ColorConstants.grey400) : Color(ColorConstants.grey600),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // レシピ本カルーセルの表示
  Widget _buildRecipeBooksCarousel(double cardHeight, bool isDarkMode, List<RecipeBook> recipeBooks) {
    return Center(
      child: SizedBox(
        height: cardHeight + UIConstants.paddingXLarge * 2,
        child: PageView.builder(
          controller: _pageController!,
          itemCount: recipeBooks.length,
          clipBehavior: Clip.none,
          itemBuilder: (context, index) {
            final recipeBook = recipeBooks[index];

            return AnimatedBuilder(
              animation: _pageController!,
              builder: (context, child) {
                final currentPage =
                    _pageController!.position.haveDimensions
                        ? _pageController!.page!
                        : _pageController!.initialPage.toDouble();

                final difference = (currentPage - index).abs();
                final scale = (UIConstants.maxCarouselScale - 
                    (difference * UIConstants.carouselScaleReduction))
                    .clamp(UIConstants.minCarouselScale, UIConstants.maxCarouselScale);

                return Transform.scale(scale: scale, child: child);
              },
              child: _buildCarouselItem(context, recipeBook, cardHeight, isDarkMode),
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
    bool isDarkMode,
  ) {
    final cardWidth = cardHeight * UIConstants.aspectRatio3to4;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: cardWidth,
          height: cardHeight,
          margin: EdgeInsets.symmetric(horizontal: UIConstants.paddingSmall),
          decoration: BoxDecoration(
            color: isDarkMode ? Color(ColorConstants.grey800) : Colors.white,
            border: Border.all(
              color: isDarkMode ? Color(ColorConstants.grey600) : Color(ColorConstants.grey300),
            ),
            borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
            boxShadow: [
              BoxShadow(
                color: isDarkMode 
                    ? Colors.black.withOpacity(ColorConstants.opacityMedium)
                    : Colors.black.withOpacity(ColorConstants.opacityLight),
                spreadRadius: UIConstants.shadowSpreadRadius,
                blurRadius: UIConstants.shadowBlurRadius,
                offset: Offset(UIConstants.shadowOffsetDx, UIConstants.shadowOffsetDy),
              ),
            ],
          ),
          child: recipeBook.coverImagePath != null
              ? FutureBuilder<bool>(
                  future: File(recipeBook.coverImagePath!).exists(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data == true) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
                        child: Image.file(
                          File(recipeBook.coverImagePath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultBookContent(recipeBook, isDarkMode);
                          },
                        ),
                      );
                    } else {
                      return _buildDefaultBookContent(recipeBook, isDarkMode);
                    }
                  },
                )
              : _buildDefaultBookContent(recipeBook, isDarkMode),
        ),
        SizedBox(height: UIConstants.paddingMedium),
        // タイトルを下部に表示（画像がある場合）
        if (recipeBook.coverImagePath != null)
          Text(
            recipeBook.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: UIConstants.fontSizeMedium,
              color: isDarkMode ? Color(ColorConstants.grey300) : Color(ColorConstants.grey700),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildLampWidget(bool isDarkMode, VoidCallback onThemeToggle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 吊り下げ棒
        Container(
          width: UIConstants.lampHangingRodWidth,
          height: UIConstants.lampHangingRodHeight,
          color: isDarkMode ? Colors.white70 : Colors.black54,
        ),
        // ランプ本体
        Stack(
          alignment: Alignment.center,
          children: [
            // ライトモード時の光エフェクト
            if (!isDarkMode)
              Positioned(
                top: 50,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.yellow.withOpacity(ColorConstants.opacityHigh),
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
              onTap: onThemeToggle,
              child: SizedBox(
                height: UIConstants.lampHeight,
                child: ColorFiltered(
                  colorFilter: isDarkMode
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
  Widget _buildDefaultBookContent(RecipeBook recipeBook, bool isDarkMode) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(UIConstants.paddingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedBook02,
              color: isDarkMode ? Color(ColorConstants.grey400) : Color(ColorConstants.grey600),
              size: UIConstants.iconSizeMedium,
            ),
            SizedBox(height: UIConstants.paddingSmall),
            Text(
              recipeBook.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: UIConstants.fontSizeLarge,
                color: isDarkMode ? Color(ColorConstants.grey200) : Color(ColorConstants.grey800),
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

  Widget _buildClockWidget(bool isDarkMode) {
    return SizedBox(
      height: UIConstants.clockHeight,
      child: ColorFiltered(
        colorFilter: isDarkMode
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
