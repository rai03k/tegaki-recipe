import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

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

  final List<String> _recipeBooks = [
    '中華料理のレシピ本',
    '和食のレシピ本',
    '洋食のレシピ本',
    'イタリアンのレシピ本',
  ];

  @override
  void initState() {
    super.initState();
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
                    child: _buildCarouselItem(
                      context,
                      _recipeBooks[itemIndex],
                      cardHeight,
                    ),
                  );
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
              color: widget.isDarkMode ? Colors.grey[600]! : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: widget.isDarkMode
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
                  color: widget.isDarkMode ? Colors.grey[200] : Colors.grey[800],
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
                  colorFilter: widget.isDarkMode
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
        colorFilter: widget.isDarkMode
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