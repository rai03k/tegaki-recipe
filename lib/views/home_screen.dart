import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';
import '../models/database.dart';
import '../view_models/recipe_book_view_model.dart';
import '../view_models/theme_view_model.dart';
import '../view_models/timer_view_model.dart';
import 'dart:io';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  PageController? _pageController;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 画面に戻ってきた時にデータを再読み込み（非同期で実行）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recipeBookNotifierProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight / 3;
    final recipeBookState = ref.watch(recipeBookNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    final isDarkMode = ref.watch(themeNotifierProvider) == ThemeMode.dark;

    // PageControllerの初期化
    if (recipeBookState.recipeBooks.isNotEmpty && _pageController == null) {
      _pageController = PageController(viewportFraction: 0.5, initialPage: 0);
    }

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      body: Stack(
        children: [
          // メインコンテンツ
          if (recipeBookState.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (recipeBookState.recipeBooks.isEmpty)
            _buildEmptyState(isDarkMode)
          else
            _buildRecipeBooksCarousel(
              cardHeight,
              isDarkMode,
              recipeBookState.recipeBooks,
            ),

          // ランプUI（ステータスバーから伸びる）
          Positioned(
            top: 0, // ステータスバーから開始
            right: 30,
            child: _buildLampWidget(
              isDarkMode,
              () => _onThemeToggle(themeNotifier),
            ),
          ),
          // 時計UI
          Positioned(top: 70, left: 40, child: _buildClockWidget(isDarkMode)),

          // 左下の家具エリア（メモ帳と棚）
          Positioned(
            bottom: 100,
            left: 20,
            child: _buildFurnitureWidgets(isDarkMode),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/create-recipe-book');
          // 画面から戻ってきたときにデータを再読み込み
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(recipeBookNotifierProvider.notifier).refresh();
          });
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
            'レシピ本がまだないよ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '右下のボタンから\nレシピ本を作ってみよう！',
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

  // レシピ本カルーセルの表示
  Widget _buildRecipeBooksCarousel(
    double cardHeight,
    bool isDarkMode,
    List<RecipeBook> recipeBooks,
  ) {
    return Center(
      child: SizedBox(
        height: cardHeight + 80,
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
                final scale = (1 - (difference * 0.2)).clamp(0.8, 1.0);

                return Transform.scale(scale: scale, child: child);
              },
              child: GestureDetector(
                onTap: () {
                  // 目次ページへの遷移
                  context.push(
                    '/table-of-contents/${recipeBook.id}',
                    extra: recipeBook,
                  );
                },
                child: _buildCarouselItem(
                  context,
                  recipeBook,
                  cardHeight,
                  isDarkMode,
                ),
              ),
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
    final cardWidth = cardHeight * (3 / 4);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: cardWidth,
          height: cardHeight,
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            border: Border.all(
              color: isDarkMode ? Colors.grey[600]! : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color:
                    isDarkMode
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
                              return _buildDefaultBookContent(
                                recipeBook,
                                isDarkMode,
                              );
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
        const SizedBox(height: 16),
        // タイトルを下部に表示（画像がある場合）
        if (recipeBook.coverImagePath != null)
          Text(
            recipeBook.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Future<void> _onThemeToggle(ThemeNotifier themeNotifier) async {
    // 音声再生
    try {
      await _audioPlayer.setAsset('assets/se/switch.mp3');
      await _audioPlayer.play();
    } catch (e) {
      // 音声再生エラーは無視して続行
    }

    // 振動
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }

    // テーマ切り替え
    themeNotifier.toggleTheme();
  }

  Widget _buildLampWidget(bool isDarkMode, VoidCallback onThemeToggle) {
    return Builder(
      builder: (context) {
        // ステータスバーの高さを取得
        final statusBarHeight = MediaQuery.of(context).padding.top;
        // 吊り下げ棒の長さをステータスバー + 余裕分に設定
        final rodHeight = statusBarHeight + 60;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 吊り下げ棒（ステータスバーから伸びる）
            Container(
              width: 1, // 少し太くして見やすく
              height: rodHeight,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            // ランプとの接続部分
            Container(
              width: 4,
              height: 2,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white70 : Colors.black54,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // ランプ本体（レスポンシブサイズ）
            GestureDetector(
              onTap: onThemeToggle,
              child: Builder(
                builder: (context) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final screenHeight = MediaQuery.of(context).size.height;

                  // 端末サイズに応じてランプサイズを調整
                  double lampSize;
                  if (screenWidth < 400) {
                    // 小さなスマホ
                    lampSize = screenHeight * 0.08; // 画面高の8%
                  } else if (screenWidth < 600) {
                    // 通常のスマホ
                    lampSize = screenHeight * 0.1; // 画面高の10%
                  } else {
                    // タブレット
                    lampSize = screenHeight * 0.12; // 画面高の12%
                  }

                  // 最小・最大サイズを制限
                  lampSize = lampSize.clamp(80.0, 180.0);

                  return SizedBox(
                    height: lampSize,
                    child: Image.asset(
                      isDarkMode
                          ? 'assets/images/furniture/lamp.png'
                          : 'assets/images/furniture/lamp_on.png',
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // デフォルトの本コンテンツ（画像がない、または読み込めない場合）
  Widget _buildDefaultBookContent(RecipeBook recipeBook, bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedBook02,
              color: isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
              size: 48.0,
            ),
            const SizedBox(height: 8),
            Text(
              recipeBook.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
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
    return Consumer(
      builder: (context, ref, child) {
        final timerData = ref.watch(timerNotifierProvider);
        final timerNotifier = ref.read(timerNotifierProvider.notifier);
        final isTimerActive = timerData.state == TimerState.running || 
                             timerData.state == TimerState.paused;
        
        return GestureDetector(
          onTap: () => context.push('/timer'),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 100,
                child: ColorFiltered(
                  colorFilter:
                      isDarkMode
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
              ),
              // タイマー実行中の表示
              if (isTimerActive)
                Positioned(
                  bottom: -5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: timerData.state == TimerState.running
                        ? (isDarkMode ? Colors.green[400] : Colors.green[600])
                        : (isDarkMode ? Colors.orange[400] : Colors.orange[600]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      timerNotifier.formatTime(timerData.remainingSeconds),
                      style: TextStyle(
                        fontFamily: 'ArmedLemon',
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFurnitureWidgets(bool isDarkMode) {
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // 端末サイズに応じて家具サイズを調整
        double furnitureSize;
        if (screenWidth < 400) {
          furnitureSize = screenHeight * 0.06; // 小さなスマホ
        } else if (screenWidth < 600) {
          furnitureSize = screenHeight * 0.08; // 通常のスマホ
        } else {
          furnitureSize = screenHeight * 0.1; // タブレット
        }

        furnitureSize = furnitureSize.clamp(60.0, 120.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // メモ帳（タップで買い物メモ画面へ）
            GestureDetector(
              onTap: () => context.push('/shopping-memo'),
              child: SizedBox(
                height: furnitureSize,
                child: ColorFiltered(
                  colorFilter:
                      isDarkMode
                          ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                          : const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.multiply,
                          ),
                  child: Image.asset(
                    'assets/images/furniture/memo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SizedBox(height: furnitureSize * 0.15),
            // 棚（タップで設定画面へ）
            GestureDetector(
              onTap: () => context.push('/settings'),
              child: SizedBox(
                height: furnitureSize * 1.1,
                child: ColorFiltered(
                  colorFilter:
                      isDarkMode
                          ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                          : const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.multiply,
                          ),
                  child: Image.asset(
                    'assets/images/furniture/tana.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
