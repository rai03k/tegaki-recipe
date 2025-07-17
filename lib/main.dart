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
      home: CarouselSampleScreen(),
    );
  }
}

class CarouselSampleScreen extends StatefulWidget {
  const CarouselSampleScreen({super.key});

  @override
  State<CarouselSampleScreen> createState() => _CarouselSampleScreenState();
}

class _CarouselSampleScreenState extends State<CarouselSampleScreen> {
  final _pageController = PageController(viewportFraction: 0.75);

  final List<String> _recipeBooks = [
    '中華料理のレシピ本',
    '和食のレシピ本',
    '洋食のレシピ本',
    'イタリアンのレシピ本',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // 基準となるカードの高さを定義
    final cardHeight = screenHeight / 3;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SizedBox(
          // PageViewの高さは、最大になるカードの高さ + 下のテキストエリアを考慮
          height: cardHeight + 80,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _recipeBooks.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.2)).clamp(0.8, 1.0);
                  }
                  // 変更点: レイアウトサイズではなく Transform.scale を使ってアニメーションさせる
                  return Transform.scale(scale: value, child: child);
                },
                // 変更点: builderの外でitemを生成し、cardHeightを渡す
                child: _buildCarouselItem(
                  context,
                  _recipeBooks[index],
                  cardHeight,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // 変更点: 引数で cardHeight を受け取るように変更
  Widget _buildCarouselItem(
    BuildContext context,
    String title,
    double cardHeight,
  ) {
    // 変更点: 高さを基準に幅を計算する
    final cardWidth = cardHeight * (3 / 4);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 変更点: AspectRatioの代わりに、サイズを直接指定したContainerを使用
        Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400, width: 2),
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
                '中華料理\nの\nレシピ本',
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
}
