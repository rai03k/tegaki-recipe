import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../view_models/theme_view_model.dart';

class ShoppingMemoScreen extends ConsumerStatefulWidget {
  const ShoppingMemoScreen({super.key});

  @override
  ConsumerState<ShoppingMemoScreen> createState() => _ShoppingMemoScreenState();
}

class _ShoppingMemoScreenState extends ConsumerState<ShoppingMemoScreen> {
  final List<String> _memoItems = [];
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeNotifierProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 戻るボタンとタイトル
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
                  Text(
                    '買い物メモ',
                    style: TextStyle(
                      fontFamily: 'ArmedLemon',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 入力フィールド
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
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        filled: true,
                        fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color:
                                isDarkMode
                                    ? Colors.grey[600]!
                                    : Colors.grey[300]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color:
                                isDarkMode
                                    ? Colors.grey[600]!
                                    : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color:
                                isDarkMode
                                    ? Colors.blue[400]!
                                    : Colors.blue[600]!,
                            width: 2,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _addMemoItem(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _addMemoItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDarkMode ? Colors.blue[400] : Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedAdd01,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // メモリスト
              Expanded(
                child:
                    _memoItems.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedShoppingCart01,
                                color:
                                    isDarkMode
                                        ? Colors.grey[400]!
                                        : Colors.grey[500]!,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '買い物リストが空です',
                                style: TextStyle(
                                  fontFamily: 'ArmedLemon',
                                  fontSize: 18,
                                  color:
                                      isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '上の入力欄から追加してみよう！',
                                style: TextStyle(
                                  fontFamily: 'ArmedLemon',
                                  fontSize: 14,
                                  color:
                                      isDarkMode
                                          ? Colors.grey[500]
                                          : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          itemCount: _memoItems.length,
                          itemBuilder: (context, index) {
                            final item = _memoItems[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isDarkMode
                                          ? Colors.grey[800]
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        isDarkMode
                                            ? Colors.grey[600]!
                                            : Colors.grey[300]!,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    HugeIcon(
                                      icon:
                                          HugeIcons
                                              .strokeRoundedShoppingBasket01,
                                      color:
                                          isDarkMode
                                              ? Colors.green[400]!
                                              : Colors.green[600]!,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: TextStyle(
                                          fontFamily: 'ArmedLemon',
                                          fontSize: 16,
                                          color:
                                              isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _removeMemoItem(index),
                                      child: HugeIcon(
                                        icon: HugeIcons.strokeRoundedDelete02,
                                        color:
                                            isDarkMode
                                                ? Colors.red[400]!
                                                : Colors.red[600]!,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
