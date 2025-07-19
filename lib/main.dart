import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => CarouselSampleScreen(
            onThemeToggle: _toggleTheme,
            isDarkMode: _isDarkMode,
          ),
        ),
        GoRoute(
          path: '/create-recipe-book',
          builder: (context, state) => CreateRecipeBookScreen(
            isDarkMode: _isDarkMode,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tegaki Recipe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'ArmedLemon',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        fontFamily: 'ArmedLemon',
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: _router,
    );
  }
}

class CarouselSampleScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const CarouselSampleScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<CarouselSampleScreen> createState() => _CarouselSampleScreenState();
}

class _CarouselSampleScreenState extends State<CarouselSampleScreen> {
  late final PageController _pageController;

  final List<String> _recipeBooks = [
    '中華料理のレシピ本',
    '和食のレシピ本',
    '洋食のレシピ本',
    'イタリアンのレシピ本',
  ];

  @override
  void initState() {
    super.initState();
    // ユーザーが調整した viewportFraction: 0.6 を使用
    _pageController = PageController(
      viewportFraction: 0.5,
      initialPage: _recipeBooks.length * 100,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight / 3;

    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.grey[100],
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              height: cardHeight + 80,
              child: PageView.builder(
                controller: _pageController,
                itemCount: null,
                clipBehavior: Clip.none,
                itemBuilder: (context, index) {
                  final itemIndex = index % _recipeBooks.length;

                  // ★変更点：ここからアニメーションのロジックを戻します
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
                    // 上のbuilderにchildとして渡されるウィジェット
                    child: _buildCarouselItem(
                      context,
                      _recipeBooks[itemIndex],
                      cardHeight,
                    ),
                  );
                  // ★変更点：ここまでがアニメーションのロジックです
                },
              ),
            ),
          ),
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

  // _buildCarouselItemウィジェットは変更ありません
  Widget _buildCarouselItem(
    BuildContext context,
    String title,
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '中華料理のレシピ本',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  color:
                      widget.isDarkMode ? Colors.grey[200] : Colors.grey[800],
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: widget.isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
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

class CreateRecipeBookScreen extends StatefulWidget {
  final bool isDarkMode;

  const CreateRecipeBookScreen({
    super.key,
    required this.isDarkMode,
  });

  @override
  State<CreateRecipeBookScreen> createState() => _CreateRecipeBookScreenState();
}

class _CreateRecipeBookScreenState extends State<CreateRecipeBookScreen> {
  final _titleController = TextEditingController();
  String? _selectedImagePath;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _selectImage() {
    // TODO: 画像選択とトリミング機能を実装
  }

  void _saveRecipeBook() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('タイトルを入力してください')),
      );
      return;
    }
    
    // TODO: データベースに保存
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 戻るボタン
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowLeft01,
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                      size: 24.0,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'レシピ本作成',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              // 表紙画像選択
              Center(
                child: GestureDetector(
                  onTap: _selectImage,
                  child: Container(
                    width: 200,
                    height: 267, // 3:4比率
                    decoration: BoxDecoration(
                      color: widget.isDarkMode ? Colors.grey[800] : Colors.white,
                      border: Border.all(
                        color: widget.isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _selectedImagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              _selectedImagePath!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedImage01,
                                color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                size: 48.0,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '表紙画像を選択',
                                style: TextStyle(
                                  color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // タイトル入力
              Text(
                'レシピ本タイトル',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'レシピ本のタイトルを入力',
                  hintStyle: TextStyle(
                    color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  filled: true,
                  fillColor: widget.isDarkMode ? Colors.grey[800] : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.deepPurple,
                      width: 2,
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // 保存ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveRecipeBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '作成',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
