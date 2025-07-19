import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../models/ingredient.dart';
import '../view_models/theme_view_model.dart';

class IngredientSelectionScreen extends ConsumerStatefulWidget {
  const IngredientSelectionScreen({super.key});

  @override
  ConsumerState<IngredientSelectionScreen> createState() => _IngredientSelectionScreenState();
}

class _IngredientSelectionScreenState extends ConsumerState<IngredientSelectionScreen> {
  final List<TextEditingController> _nameControllers = [TextEditingController()];
  final List<TextEditingController> _amountControllers = [TextEditingController()];
  final List<FocusNode> _nameFocusNodes = [FocusNode()];
  final List<FocusNode> _amountFocusNodes = [FocusNode()];
  
  List<Ingredient> _suggestions = [];
  int _currentEditingIndex = -1;

  @override
  void dispose() {
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    for (final controller in _amountControllers) {
      controller.dispose();
    }
    for (final focusNode in _nameFocusNodes) {
      focusNode.dispose();
    }
    for (final focusNode in _amountFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onIngredientNameChanged(String value, int index) {
    setState(() {
      _currentEditingIndex = index;
      _suggestions = IngredientData.searchByName(value);
    });
  }

  void _selectIngredient(Ingredient ingredient, int index) {
    setState(() {
      _nameControllers[index].text = ingredient.name;
      _suggestions = [];
      _currentEditingIndex = -1;
      
      // フォーカスを分量フィールドに移動
      _amountFocusNodes[index].requestFocus();
    });
  }

  void _addNewIngredientRow() {
    setState(() {
      _nameControllers.add(TextEditingController());
      _amountControllers.add(TextEditingController());
      _nameFocusNodes.add(FocusNode());
      _amountFocusNodes.add(FocusNode());
    });
  }

  void _removeIngredientRow(int index) {
    if (_nameControllers.length > 1) {
      setState(() {
        _nameControllers[index].dispose();
        _amountControllers[index].dispose();
        _nameFocusNodes[index].dispose();
        _amountFocusNodes[index].dispose();
        
        _nameControllers.removeAt(index);
        _amountControllers.removeAt(index);
        _nameFocusNodes.removeAt(index);
        _amountFocusNodes.removeAt(index);
        
        if (_currentEditingIndex == index) {
          _suggestions = [];
          _currentEditingIndex = -1;
        }
      });
    }
  }

  void _saveIngredients() {
    final ingredients = <RecipeIngredient>[];
    
    for (int i = 0; i < _nameControllers.length; i++) {
      final name = _nameControllers[i].text.trim();
      final amount = _amountControllers[i].text.trim();
      
      if (name.isNotEmpty && amount.isNotEmpty) {
        // 定義済み材料から背景色とアイコンを取得
        final predefinedIngredient = IngredientData.predefinedIngredients
            .where((ingredient) => ingredient.name == name)
            .firstOrNull;
        
        ingredients.add(RecipeIngredient(
          name: name,
          amount: amount,
          iconPath: predefinedIngredient?.iconPath,
          backgroundColor: predefinedIngredient?.backgroundColor,
        ));
      }
    }
    
    // 前画面に材料データを返す
    context.pop(ingredients);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeNotifierProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
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
                    '材料選択',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontFamily: 'ArmedLemon',
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _saveIngredients,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '完了',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // メインコンテンツ
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 説明テキスト
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '材料名を入力すると候補が表示されます。\n分量も忘れずに入力してくださいね！',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 材料入力フォーム
                    ...List.generate(_nameControllers.length, (index) {
                      return _buildIngredientRow(index, isDarkMode);
                    }),

                    // 材料候補表示
                    if (_suggestions.isNotEmpty && _currentEditingIndex >= 0)
                      _buildSuggestionsList(isDarkMode),

                    const SizedBox(height: 16),

                    // 材料追加ボタン
                    GestureDetector(
                      onTap: _addNewIngredientRow,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.deepPurple,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedAdd01,
                              color: Colors.deepPurple,
                              size: 20.0,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '材料を追加',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientRow(int index, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // 材料名入力
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _nameControllers[index],
                focusNode: _nameFocusNodes[index],
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: '材料名',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) => _onIngredientNameChanged(value, index),
                onTap: () {
                  setState(() {
                    _currentEditingIndex = index;
                    if (_nameControllers[index].text.isNotEmpty) {
                      _suggestions = IngredientData.searchByName(_nameControllers[index].text);
                    }
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // 分量入力
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _amountControllers[index],
                focusNode: _amountFocusNodes[index],
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: '分量',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  // 分量が入力されたら新しい行を自動追加
                  if (value.isNotEmpty && 
                      _nameControllers[index].text.isNotEmpty && 
                      index == _nameControllers.length - 1) {
                    _addNewIngredientRow();
                  }
                },
              ),
            ),
          ),
          
          // 削除ボタン
          if (_nameControllers.length > 1)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () => _removeIngredientRow(index),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedDelete02,
                    color: Colors.red,
                    size: 20.0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              '候補の材料',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...List.generate(_suggestions.length, (index) {
            final ingredient = _suggestions[index];
            return GestureDetector(
              onTap: () => _selectIngredient(ingredient, _currentEditingIndex),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: index < _suggestions.length - 1
                      ? Border(
                          bottom: BorderSide(
                            color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                            width: 1,
                          ),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    // アイコン背景
                    Stack(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: ingredient.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        // TODO: 実際の画像アイコンを表示（アイコンファイルが存在する場合）
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              ingredient.name.substring(0, 1),
                              style: TextStyle(
                                color: isDarkMode ? Colors.black : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // 材料名
                    Expanded(
                      child: Text(
                        ingredient.name,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // カテゴリ
                    if (ingredient.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          ingredient.category!,
                          style: const TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}