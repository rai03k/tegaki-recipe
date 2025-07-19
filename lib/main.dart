import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
      home: CarouselSampleScreen(
        onThemeToggle: _toggleTheme,
        isDarkMode: _isDarkMode,
      ),
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
      backgroundColor: Colors.grey[100],
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
          Positioned(
            top: 40,
            right: 20,
            child: _buildLampWidget(),
          ),
        ],
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
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
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
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(title, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildLampWidget() {
    return GestureDetector(
      onTap: widget.onThemeToggle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 吊り下げ棒
          Container(
            width: 2,
            height: 30,
            color: widget.isDarkMode ? Colors.white70 : Colors.black54,
          ),
          // ランプ本体
          Stack(
            alignment: Alignment.center,
            children: [
              // ランプ画像
              Container(
                width: 60,
                height: 60,
                child: Image.asset(
                  'assets/images/furniture/lamp.png',
                  fit: BoxFit.contain,
                ),
              ),
              // ライトモード時の光エフェクト
              if (!widget.isDarkMode)
                Container(
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
            ],
          ),
        ],
      ),
    );
  }
}
