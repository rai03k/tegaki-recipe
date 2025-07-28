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
import '../utils/responsive_size.dart';
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
    print('🎵 AudioPlayer 初期化完了');
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
            right: 40.wpu(context),
            child: _buildLampWidget(
              isDarkMode,
              () => _onThemeToggle(themeNotifier),
            ),
          ),
          // 時計UI
          Positioned(
            top: 60.hfpu(context),
            left: 40.wpu(context),
            child: _buildClockWidget(isDarkMode),
          ),

          // 左下の家具エリア（メモ帳と棚）
          Positioned(
            bottom: 20,
            left: 0,
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
    print('🎯 テーマ切り替えタップ開始');
    
    // 音声再生
    try {
      print('🔊 音声ファイル読み込み開始');
      await _audioPlayer.setAsset('assets/se/switch.mp3');
      print('🔊 音声ファイル読み込み完了');
      
      print('🔊 音声再生開始');
      _audioPlayer.play(); // awaitを外して非同期で実行
      print('🔊 音声再生コマンド実行完了');
    } catch (e) {
      print('❌ 音声再生エラー: $e');
    }

    // 振動（音声と並行実行）
    try {
      print('📳 バイブレーションチェック開始');
      final hasVibrator = await Vibration.hasVibrator();
      print('📳 バイブレーター有無: $hasVibrator');
      
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 100); // awaitを外して非同期で実行
        print('📳 バイブレーション実行完了');
      } else {
        print('📳 バイブレーターなし');
      }
    } catch (e) {
      print('❌ バイブレーションエラー: $e');
    }

    // テーマ切り替え
    themeNotifier.toggleTheme();
    print('🎯 テーマ切り替え完了');
  }

  Widget _buildLampWidget(bool isDarkMode, VoidCallback onThemeToggle) {
    return Builder(
      builder: (context) {
        // ステータスバーの高さを取得
        final statusBarHeight = MediaQuery.of(context).padding.top;
        // 吊り下げ棒の長さをステータスバー + 余裕分に設定
        final rodHeight = statusBarHeight + 60.hfpu(context);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 吊り下げ棒（ステータスバーから伸びる）
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Container(
                width: 1, // 少し太くして見やすく
                height: rodHeight,
                color: isDarkMode ? Colors.grey[300]! : Colors.black54,
              ),
            ),
            // ランプとの接続部分
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Container(
                width: 4,
                height: 2,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[300]! : Colors.black54,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // ランプ本体（レスポンシブサイズ）
            GestureDetector(
              onTap: onThemeToggle,
              child: Builder(
                builder: (context) {
                  // ランプサイズを画面高さの比率で計算
                  final screenHeight = MediaQuery.of(context).size.height;
                  final lampSize = screenHeight / 10; // 画面高の1/4

                  return SizedBox(
                    height: lampSize,
                    child: ColorFiltered(
                      colorFilter:
                          isDarkMode
                              ? ColorFilter.mode(
                                Colors.grey[300]!,
                                BlendMode.srcIn,
                              )
                              : const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.multiply,
                              ),
                      child: Image.asset(
                        isDarkMode
                            ? 'assets/images/furniture/lamp.png'
                            : 'assets/images/furniture/lamp_on.png',
                        fit: BoxFit.contain,
                      ),
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

  // 時計
  Widget _buildClockWidget(bool isDarkMode) {
    return Consumer(
      builder: (context, ref, child) {
        final timerData = ref.watch(timerNotifierProvider);
        final timerNotifier = ref.read(timerNotifierProvider.notifier);
        final isTimerActive =
            timerData.state == TimerState.running ||
            timerData.state == TimerState.paused;

        return GestureDetector(
          onTap: () => context.push('/timer'),
          child: SizedBox(
            height: 110.hfpu(context), // 高さベースレスポンシブサイズでタイマー表示のための余裕を追加
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 100.hfpu(context), // 高さベースレスポンシブサイズで時計サイズ
                  child: ColorFiltered(
                    colorFilter:
                        isDarkMode
                            ? ColorFilter.mode(
                              Colors.grey[300]!,
                              BlendMode.srcIn,
                            )
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
                    bottom: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:
                            timerData.state == TimerState.running
                                ? (isDarkMode
                                    ? Colors.green[400]
                                    : Colors.green[600])
                                : (isDarkMode
                                    ? Colors.orange[400]
                                    : Colors.orange[600]),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        timerNotifier.formatTime(timerData.remainingSeconds),
                        style: TextStyle(
                          fontFamily: 'ArmedLemon',
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 家具エリア全体のレイアウト管理
  Widget _buildFurnitureWidgets(bool isDarkMode) {
    return Builder(
      builder: (context) {
        // 画面縦幅（高さ）の比率で家具サイズを計算
        final screenHeight = MediaQuery.of(context).size.height;
        final memoSize = screenHeight / 10; // 画面高の1/10
        final shelfSize = screenHeight / 4; // 画面高の1/4

        // Stackの全体サイズを計算（棚のサイズ + メモ帳の少しの余裕）
        final stackHeight = shelfSize * 1.3;
        final stackWidth = shelfSize * 1.5;

        return SizedBox(
          width: stackWidth,
          height: stackHeight,
          child: Stack(
            children: [
              // 棚（背景）
              Positioned(
                bottom: 0,
                left: -30,
                child: _buildShelfWidget(isDarkMode, shelfSize),
              ),
              // メモ帳（前景）
              Positioned(
                top: stackHeight * 0.2, // 上から10%の位置
                left: stackWidth * 0.15, // 左から10%の位置
                child: _buildMemoWidget(isDarkMode, memoSize),
              ),
            ],
          ),
        );
      },
    );
  }

  // 共通の家具アイテム構築ヘルパー
  Widget _buildFurnitureItem({
    required String assetPath,
    required VoidCallback onTap,
    required double size,
    required bool isDarkMode,
    double heightMultiplier = 1.0,
    double aspectRatio = 1.0, // アスペクト比を追加
  }) {
    final height = size * heightMultiplier;
    final width = height * aspectRatio; // 高さに基づいて幅を計算

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: ColorFiltered(
          colorFilter:
              isDarkMode
                  ? ColorFilter.mode(Colors.grey[300]!, BlendMode.srcIn)
                  : const ColorFilter.mode(
                    Colors.transparent,
                    BlendMode.multiply,
                  ),
          child: Image.asset(assetPath, fit: BoxFit.contain),
        ),
      ),
    );
  }

  // メモ帳ウィジェット（買い物メモ画面へ遷移）
  Widget _buildMemoWidget(bool isDarkMode, double furnitureSize) {
    return _buildFurnitureItem(
      assetPath: 'assets/images/furniture/memo.png',
      onTap: () => context.push('/shopping-memo'),
      size: furnitureSize,
      isDarkMode: isDarkMode,
      aspectRatio: 0.7, // メモ帳は縦長（幅：高さ = 0.7：1）
    );
  }

  // 棚ウィジェット（設定画面へ遷移）
  Widget _buildShelfWidget(bool isDarkMode, double furnitureSize) {
    return _buildFurnitureItem(
      assetPath: 'assets/images/furniture/tana.png',
      onTap: () => context.push('/settings'),
      size: furnitureSize,
      isDarkMode: isDarkMode,
      heightMultiplier: 1.1,
      aspectRatio: 1.2, // 棚は横長（幅：高さ = 1.2：1）
    );
  }
}
