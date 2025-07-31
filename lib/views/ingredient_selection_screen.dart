import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../models/ingredient.dart';
import '../view_models/theme_view_model.dart';

class IngredientSelectionScreen extends ConsumerStatefulWidget {
  final List<RecipeIngredient>? existingIngredients;
  
  const IngredientSelectionScreen({
    super.key,
    this.existingIngredients,
  });

  @override
  ConsumerState<IngredientSelectionScreen> createState() =>
      _IngredientSelectionScreenState();
}

class _IngredientSelectionScreenState
    extends ConsumerState<IngredientSelectionScreen> {
  // 食材用のコントローラー
  final List<TextEditingController> _nameControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> _amountControllers = [
    TextEditingController(),
  ];
  final List<FocusNode> _nameFocusNodes = [FocusNode()];
  final List<FocusNode> _amountFocusNodes = [FocusNode()];

  // 調味料用のコントローラー
  final List<TextEditingController> _seasoningNameControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> _seasoningAmountControllers = [
    TextEditingController(),
  ];
  final List<FocusNode> _seasoningNameFocusNodes = [FocusNode()];
  final List<FocusNode> _seasoningAmountFocusNodes = [FocusNode()];

  List<Ingredient> _suggestions = [];
  int _currentEditingIndex = -1;
  String _currentEditingType = 'ingredient'; // 'ingredient' or 'seasoning'

  @override
  void initState() {
    super.initState();
    _initializeWithExistingIngredients();
  }

  void _initializeWithExistingIngredients() {
    if (widget.existingIngredients == null || widget.existingIngredients!.isEmpty) {
      return; // 既存材料がない場合は何もしない
    }

    // 既存のコントローラーをクリア
    _clearAllControllers();

    // 食材と調味料に分類
    final ingredients = <RecipeIngredient>[];
    final seasonings = <RecipeIngredient>[];

    for (final ingredient in widget.existingIngredients!) {
      // 定義済み材料から調味料かどうかを判定
      final predefinedIngredient = IngredientData.predefinedIngredients
          .where((item) => item.name == ingredient.name)
          .firstOrNull;
      
      if (predefinedIngredient?.category == '調味料') {
        seasonings.add(ingredient);
      } else {
        ingredients.add(ingredient);
      }
    }

    // 食材コントローラーを設定
    _setupIngredientsControllers(ingredients);
    
    // 調味料コントローラーを設定
    _setupSeasoningsControllers(seasonings);
  }

  void _clearAllControllers() {
    // 既存のコントローラーを全て破棄
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
    
    for (final controller in _seasoningNameControllers) {
      controller.dispose();
    }
    for (final controller in _seasoningAmountControllers) {
      controller.dispose();
    }
    for (final focusNode in _seasoningNameFocusNodes) {
      focusNode.dispose();
    }
    for (final focusNode in _seasoningAmountFocusNodes) {
      focusNode.dispose();
    }

    // リストをクリア
    _nameControllers.clear();
    _amountControllers.clear();
    _nameFocusNodes.clear();
    _amountFocusNodes.clear();
    _seasoningNameControllers.clear();
    _seasoningAmountControllers.clear();
    _seasoningNameFocusNodes.clear();
    _seasoningAmountFocusNodes.clear();
  }

  void _setupIngredientsControllers(List<RecipeIngredient> ingredients) {
    for (final ingredient in ingredients) {
      _nameControllers.add(TextEditingController(text: ingredient.name));
      _amountControllers.add(TextEditingController(text: ingredient.amount));
      _nameFocusNodes.add(FocusNode());
      _amountFocusNodes.add(FocusNode());
    }
    
    // 最後に空の行を追加
    if (_nameControllers.isEmpty) {
      _nameControllers.add(TextEditingController());
      _amountControllers.add(TextEditingController());
      _nameFocusNodes.add(FocusNode());
      _amountFocusNodes.add(FocusNode());
    }
  }

  void _setupSeasoningsControllers(List<RecipeIngredient> seasonings) {
    for (final seasoning in seasonings) {
      _seasoningNameControllers.add(TextEditingController(text: seasoning.name));
      _seasoningAmountControllers.add(TextEditingController(text: seasoning.amount));
      _seasoningNameFocusNodes.add(FocusNode());
      _seasoningAmountFocusNodes.add(FocusNode());
    }
    
    // 最後に空の行を追加
    if (_seasoningNameControllers.isEmpty) {
      _seasoningNameControllers.add(TextEditingController());
      _seasoningAmountControllers.add(TextEditingController());
      _seasoningNameFocusNodes.add(FocusNode());
      _seasoningAmountFocusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    // 食材用のdispose
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

    // 調味料用のdispose
    for (final controller in _seasoningNameControllers) {
      controller.dispose();
    }
    for (final controller in _seasoningAmountControllers) {
      controller.dispose();
    }
    for (final focusNode in _seasoningNameFocusNodes) {
      focusNode.dispose();
    }
    for (final focusNode in _seasoningAmountFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onIngredientNameChanged(String value, int index, String type) {
    print('📝 _onIngredientNameChanged called:');
    print('  - value: "$value"');
    print('  - index: $index');
    print('  - type: $type');

    setState(() {
      _currentEditingIndex = index;
      _currentEditingType = type;

      if (value.isEmpty) {
        // 空の場合は候補を表示しない
        _suggestions = [];
      } else {
        // 入力値に基づいて候補を検索
        final allResults = IngredientData.searchByName(value);

        if (type == 'seasoning') {
          // 調味料のみをフィルタリング
          _suggestions =
              allResults
                  .where((ingredient) => ingredient.category == '調味料')
                  .take(5) // 最大5件に制限
                  .toList();
        } else {
          // 調味料以外をフィルタリング
          _suggestions =
              allResults
                  .where((ingredient) => ingredient.category != '調味料')
                  .take(5) // 最大5件に制限
                  .toList();
        }

        // 新仕様: 材料名を入力したら次の行を自動追加
        _addNewRowIfNeeded(type, index);
      }
    });
  }

  void _addNewRowIfNeeded(String type, int currentIndex) {
    if (type == 'seasoning') {
      // 調味料の場合：最後の行で入力していて、まだ追加の空行がない場合
      if (currentIndex == _seasoningNameControllers.length - 1) {
        _addNewSeasoningRow();
      }
    } else {
      // 食材の場合：最後の行で入力していて、まだ追加の空行がない場合
      if (currentIndex == _nameControllers.length - 1) {
        _addNewIngredientRow();
      }
    }
  }

  void _selectIngredient(Ingredient ingredient, int index) {
    // 入力範囲チェック
    if (_currentEditingType == 'seasoning') {
      if (index >= _seasoningNameControllers.length) return;
    } else {
      if (index >= _nameControllers.length) return;
    }

    setState(() {
      if (_currentEditingType == 'seasoning') {
        _seasoningNameControllers[index].text = ingredient.name;
      } else {
        _nameControllers[index].text = ingredient.name;
      }

      // 候補リストをクリア
      _suggestions.clear();
      _currentEditingIndex = -1;
    });

    // 新仕様: 候補選択後、即座に分量フィールドにフォーカス移動
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_currentEditingType == 'seasoning') {
        if (index < _seasoningAmountFocusNodes.length) {
          _seasoningAmountFocusNodes[index].requestFocus();
        }
      } else {
        if (index < _amountFocusNodes.length) {
          _amountFocusNodes[index].requestFocus();
        }
      }
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

  void _addNewSeasoningRow() {
    setState(() {
      _seasoningNameControllers.add(TextEditingController());
      _seasoningAmountControllers.add(TextEditingController());
      _seasoningNameFocusNodes.add(FocusNode());
      _seasoningAmountFocusNodes.add(FocusNode());
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

        if (_currentEditingIndex == index &&
            _currentEditingType == 'ingredient') {
          _suggestions = [];
          _currentEditingIndex = -1;
        }
      });
    }
  }

  void _removeSeasoningRow(int index) {
    if (_seasoningNameControllers.length > 1) {
      setState(() {
        _seasoningNameControllers[index].dispose();
        _seasoningAmountControllers[index].dispose();
        _seasoningNameFocusNodes[index].dispose();
        _seasoningAmountFocusNodes[index].dispose();

        _seasoningNameControllers.removeAt(index);
        _seasoningAmountControllers.removeAt(index);
        _seasoningNameFocusNodes.removeAt(index);
        _seasoningAmountFocusNodes.removeAt(index);

        if (_currentEditingIndex == index &&
            _currentEditingType == 'seasoning') {
          _suggestions = [];
          _currentEditingIndex = -1;
        }
      });
    }
  }

  void _saveIngredients() {
    final ingredients = <RecipeIngredient>[];

    // 食材を追加
    for (int i = 0; i < _nameControllers.length; i++) {
      final name = _nameControllers[i].text.trim();
      final amount = _amountControllers[i].text.trim();

      // 新仕様: 材料名があれば保存（分量は空でもOK）
      if (name.isNotEmpty) {
        // 定義済み材料から背景色とアイコンを取得
        final predefinedIngredient =
            IngredientData.predefinedIngredients
                .where((ingredient) => ingredient.name == name)
                .firstOrNull;

        ingredients.add(
          RecipeIngredient(
            name: name,
            amount: amount, // 空でもそのまま保存
            iconPath: predefinedIngredient?.iconPath,
            backgroundColor: predefinedIngredient?.backgroundColor,
          ),
        );
      }
    }

    // 調味料を追加
    for (int i = 0; i < _seasoningNameControllers.length; i++) {
      final name = _seasoningNameControllers[i].text.trim();
      final amount = _seasoningAmountControllers[i].text.trim();

      // 新仕様: 材料名があれば保存（分量は空でもOK）
      if (name.isNotEmpty) {
        // 定義済み調味料から背景色とアイコンを取得
        final predefinedIngredient =
            IngredientData.predefinedIngredients
                .where((ingredient) => ingredient.name == name)
                .firstOrNull;

        ingredients.add(
          RecipeIngredient(
            name: name,
            amount: amount, // 空でもそのまま保存
            iconPath: predefinedIngredient?.iconPath,
            backgroundColor: predefinedIngredient?.backgroundColor,
          ),
        );
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                physics: const ClampingScrollPhysics(), // タッチイベントの競合を減らす
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 食材セクション
                    _buildSectionTitle('食材', isDarkMode),
                    const SizedBox(height: 12),

                    // 食材入力フォーム
                    ...List.generate(_nameControllers.length, (index) {
                      return Column(
                        children: [
                          _buildIngredientRow(index, isDarkMode, 'ingredient'),
                          // 候補表示（このフィールドが編集中の場合）
                          Builder(
                            builder: (context) {
                              final shouldShow =
                                  _suggestions.isNotEmpty &&
                                  _currentEditingIndex == index &&
                                  _currentEditingType == 'ingredient';

                              if (shouldShow) {
                                return _buildFullWidthSuggestionsList(
                                  isDarkMode,
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      );
                    }),

                    // 食材追加ボタン
                    _buildAddButton('食材を追加', _addNewIngredientRow, isDarkMode),
                    const SizedBox(height: 24),

                    // 調味料セクション
                    _buildSectionTitle('調味料', isDarkMode),
                    const SizedBox(height: 12),

                    // 調味料入力フォーム
                    ...List.generate(_seasoningNameControllers.length, (index) {
                      return Column(
                        children: [
                          _buildIngredientRow(index, isDarkMode, 'seasoning'),
                          // 候補表示（このフィールドが編集中の場合）
                          Builder(
                            builder: (context) {
                              final shouldShow =
                                  _suggestions.isNotEmpty &&
                                  _currentEditingIndex == index &&
                                  _currentEditingType == 'seasoning';

                              if (shouldShow) {
                                return _buildFullWidthSuggestionsList(
                                  isDarkMode,
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      );
                    }),

                    // 調味料追加ボタン
                    _buildAddButton('調味料を追加', _addNewSeasoningRow, isDarkMode),
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

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildAddButton(String text, VoidCallback onTap, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
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
                size: 18.0,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientRow(int index, bool isDarkMode, String type) {
    final nameControllers =
        type == 'seasoning' ? _seasoningNameControllers : _nameControllers;
    final amountControllers =
        type == 'seasoning' ? _seasoningAmountControllers : _amountControllers;
    final nameFocusNodes =
        type == 'seasoning' ? _seasoningNameFocusNodes : _nameFocusNodes;
    final amountFocusNodes =
        type == 'seasoning' ? _seasoningAmountFocusNodes : _amountFocusNodes;
    final hintText = type == 'seasoning' ? '調味料名' : '材料名';

    // 選択された材料の情報を取得
    final selectedIngredient =
        nameControllers[index].text.isNotEmpty
            ? IngredientData.predefinedIngredients
                .where(
                  (ingredient) =>
                      ingredient.name == nameControllers[index].text,
                )
                .firstOrNull
            : null;

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
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nameControllers[index],
                      focusNode: nameFocusNodes[index],
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: TextStyle(
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        _onIngredientNameChanged(value, index, type);
                      },
                      onTap: () {
                        setState(() {
                          _currentEditingIndex = index;
                          _currentEditingType = type;
                          if (nameControllers[index].text.isNotEmpty) {
                            if (type == 'seasoning') {
                              _suggestions =
                                  IngredientData.searchByName(
                                        nameControllers[index].text,
                                      )
                                      .where(
                                        (ingredient) =>
                                            ingredient.category == '調味料',
                                      )
                                      .toList();
                            } else {
                              _suggestions =
                                  IngredientData.searchByName(
                                        nameControllers[index].text,
                                      )
                                      .where(
                                        (ingredient) =>
                                            ingredient.category != '調味料',
                                      )
                                      .toList();
                            }
                          } else {
                            _suggestions = [];
                          }
                        });
                      },
                      onTapOutside: (event) {
                        // フィールド外をタップした時に候補を非表示
                        if (_currentEditingIndex == index &&
                            _currentEditingType == type) {
                          setState(() {
                            _suggestions = [];
                            _currentEditingIndex = -1;
                          });
                        }
                      },
                    ),
                  ),
                  // 選択された材料の画像を右側に表示
                  if (selectedIngredient != null)
                    _buildSelectedIngredientImage(selectedIngredient),
                ],
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
                controller: amountControllers[index],
                focusNode: amountFocusNodes[index],
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                // 新仕様では分量入力時の自動行追加は行わない
                onChanged: (value) {},
              ),
            ),
          ),

          // 削除ボタン
          if (nameControllers.length > 1)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap:
                    () =>
                        type == 'seasoning'
                            ? _removeSeasoningRow(index)
                            : _removeIngredientRow(index),
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

  Widget _buildFullWidthSuggestionsList(bool isDarkMode) {
    print('🏗️ _buildFullWidthSuggestionsList called');
    print('  - _suggestions.length: ${_suggestions.length}');
    print('  - _currentEditingIndex: $_currentEditingIndex');
    print('  - _currentEditingType: $_currentEditingType');
    for (int i = 0; i < _suggestions.length; i++) {
      print('  - Suggestion $i: ${_suggestions[i].name}');
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      padding: const EdgeInsets.all(16),
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
          Text(
            _currentEditingType == 'seasoning' ? '候補の調味料' : '候補の食材',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // 候補リストを縦一列で表示
          Listener(
            behavior: HitTestBehavior.opaque,
            child: Column(
              children:
                  _suggestions.map((ingredient) {
                    return _buildIngredientSuggestionItem(
                      ingredient,
                      isDarkMode,
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientSuggestionItem(
    Ingredient ingredient,
    bool isDarkMode,
  ) {
    print('🧩 Building suggestion item: ${ingredient.name}');
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // タップ領域を確実に設定
      onTap: () {
        print('🔥 SUGGESTION TAPPED: ${ingredient.name}');
        print('  - _currentEditingIndex: $_currentEditingIndex');
        print('  - _currentEditingType: $_currentEditingType');

        // 確実に選択処理を実行
        if (_currentEditingIndex >= 0) {
          print('  - Calling _selectIngredient...');
          _selectIngredient(ingredient, _currentEditingIndex);
        } else {
          print('  - ERROR: _currentEditingIndex is invalid!');
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[700] : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: ingredient.backgroundColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 材料画像またはアイコン
            _buildSuggestionIcon(ingredient),
            const SizedBox(width: 12),

            // 材料名
            Expanded(
              child: Text(
                ingredient.name,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // カテゴリ表示
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ingredient.backgroundColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ingredient.category ?? '',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyTestSuggestions(bool isDarkMode, int index) {
    print('🚨 Building EMERGENCY test suggestions for index $index');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Column(
        children: [
          Text(
            '🚨 緊急テスト候補',
            style: TextStyle(
              color: Colors.red[800],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // 超シンプルなボタンで直接テスト
          ...[
            _buildEmergencyTestButton('玉ねぎ', index, isDarkMode),
            const SizedBox(height: 4),
            _buildEmergencyTestButton('にんじん', index, isDarkMode),
            const SizedBox(height: 4),
            _buildEmergencyTestButton('じゃがいも', index, isDarkMode),
          ],
        ],
      ),
    );
  }

  Widget _buildEmergencyTestButton(
    String ingredientName,
    int index,
    bool isDarkMode,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        print('🚨🚨🚨 EMERGENCY BUTTON TAPPED: $ingredientName');
        print('  - index: $index');
        print('  - _currentEditingType: $_currentEditingType');

        // 直接テキストを設定
        setState(() {
          _nameControllers[index].text = ingredientName;
          _currentEditingIndex = -1;
        });

        print('  - Set text: ${_nameControllers[index].text}');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text(
          ingredientName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSuggestionIcon(Ingredient ingredient) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: ingredient.backgroundColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          ingredient.iconPath,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: ingredient.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  ingredient.name.isNotEmpty
                      ? ingredient.name.substring(0, 1)
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIngredientImage(Ingredient ingredient) {
    return FutureBuilder<bool>(
      future: _imageExists(ingredient.iconPath),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                ingredient.iconPath,
                width: 24,
                height: 24,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSelectedIngredientImage(Ingredient ingredient) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              ingredient.iconPath,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: ingredient.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      ingredient.name.substring(0, 1),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 色付きバッジ（右下）
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: ingredient.backgroundColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _imageExists(String path) async {
    try {
      await DefaultAssetBundle.of(context).load(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget _buildIngredientChip(Ingredient ingredient, bool isDarkMode) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('🎯 Chip tapped: ${ingredient.name}');
          print('  - Current editing index: $_currentEditingIndex');
          print('  - Current editing type: $_currentEditingType');
          _selectIngredient(ingredient, _currentEditingIndex);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ingredient.backgroundColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 材料名
              Text(
                ingredient.name,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // 材料画像（右側、画像がある場合のみ）
              // 一時的に画像を無効化してテスト
              // _buildIngredientImage(ingredient),
            ],
          ),
        ),
      ),
    );
  }
}
