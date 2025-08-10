import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../view_models/theme_view_model.dart';

class ShoppingMemoOverlay extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const ShoppingMemoOverlay({
    super.key,
    required this.onClose,
  });

  @override
  ConsumerState<ShoppingMemoOverlay> createState() => _ShoppingMemoOverlayState();
}

class _ShoppingMemoOverlayState extends ConsumerState<ShoppingMemoOverlay>
    with SingleTickerProviderStateMixin {
  final List<String> _memoItems = [];
  final TextEditingController _textController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _addMemoItem() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _memoItems.add(text);
        _textController.clear();
      });
    }
  }

  void _removeMemoItem(int index) {
    setState(() {
      _memoItems.removeAt(index);
    });
  }

  void _closeOverlay() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeNotifierProvider) == ThemeMode.dark;
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: Stack(
            clipBehavior: Clip.none,
            children: [
              // 背景のオーバーレイ（タップで閉じる）
              GestureDetector(
                onTap: _closeOverlay,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5 * _fadeAnimation.value),
                ),
              ),

            // 買い物メモのコンテンツ
            Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    width: screenSize.width * 0.9,
                    height: screenSize.height * 0.8,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // ヘッダー
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withValues(alpha: 0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedShoppingBasket03,
                                color: Colors.deepPurple,
                                size: 28,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  '買い物メモ',
                                  style: TextStyle(
                                    fontFamily: 'ArmedLemon',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _closeOverlay,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedCancel01,
                                    color: isDarkMode ? Colors.white70 : Colors.black54,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // コンテンツ
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                // 入力フィールド（キーボードの影響を受けないように固定）
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _textController,
                                        style: TextStyle(
                                          fontFamily: 'ArmedLemon',
                                          fontSize: 16,
                                          color: isDarkMode ? Colors.white : Colors.black,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: '買い物アイテムを入力...',
                                          hintStyle: TextStyle(
                                            fontFamily: 'ArmedLemon',
                                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                          ),
                                          filled: true,
                                          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                        ),
                                        onSubmitted: (_) => _addMemoItem(),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: _addMemoItem,
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const HugeIcon(
                                          icon: HugeIcons.strokeRoundedAdd01,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // アイテムリスト
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: _memoItems.isEmpty
                                        ? SizedBox(
                                            height: 200,
                                            child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              HugeIcon(
                                                icon: HugeIcons.strokeRoundedShoppingBasket01,
                                                color: Colors.grey[400] ?? Colors.grey,
                                                size: 48,
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                '買い物アイテムを追加してください',
                                                style: TextStyle(
                                                  fontFamily: 'ArmedLemon',
                                                  fontSize: 16,
                                                  color: Colors.grey[500] ?? Colors.grey,
                                                ),
                                              ),
                                              ],
                                            ),
                                          ),
                                        )
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                          itemCount: _memoItems.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              margin: const EdgeInsets.only(bottom: 8),
                                              decoration: BoxDecoration(
                                                color: isDarkMode 
                                                    ? Colors.grey[800] 
                                                    : Colors.grey[50],
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: ListTile(
                                                leading: Container(
                                                  width: 24,
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                    color: Colors.deepPurple.withValues(alpha: 0.2),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: const HugeIcon(
                                                    icon: HugeIcons.strokeRoundedShoppingCart01,
                                                    color: Colors.deepPurple,
                                                    size: 16,
                                                  ),
                                                ),
                                                title: Text(
                                                  _memoItems[index],
                                                  style: TextStyle(
                                                    fontFamily: 'ArmedLemon',
                                                    fontSize: 16,
                                                    color: isDarkMode ? Colors.white : Colors.black,
                                                  ),
                                                ),
                                                trailing: GestureDetector(
                                                  onTap: () => _removeMemoItem(index),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: const HugeIcon(
                                                      icon: HugeIcons.strokeRoundedDelete02,
                                                      color: Colors.red,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
}