import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../models/ingredient.dart';
import '../view_models/theme_view_model.dart';
import '../view_models/ingredient_selection_view_model.dart';

class IngredientSelectionScreen extends ConsumerStatefulWidget {
  final List<RecipeIngredient>? existingIngredients;

  const IngredientSelectionScreen({super.key, this.existingIngredients});

  @override
  ConsumerState<IngredientSelectionScreen> createState() =>
      _IngredientSelectionScreenState();
}

class _IngredientSelectionScreenState
    extends ConsumerState<IngredientSelectionScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ingredientSelectionViewModelProvider.notifier)
          .initializeWithExistingIngredients(widget.existingIngredients);
    });
  }


  void _saveIngredients() {
    final ingredients = ref.read(ingredientSelectionViewModelProvider.notifier).saveIngredients();
    context.pop(ingredients);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeNotifierProvider) == ThemeMode.dark;
    final state = ref.watch(ingredientSelectionViewModelProvider);
    final viewModel = ref.watch(ingredientSelectionViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
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
                      ...List.generate(state.nameControllers.length, (index) {
                        return Column(
                          children: [
                            _buildIngredientRow(
                              index,
                              isDarkMode,
                              'ingredient',
                            ),
                            // 候補表示（このフィールドが編集中の場合）
                            Builder(
                              builder: (context) {
                                final shouldShow =
                                    state.suggestions.isNotEmpty &&
                                    state.currentEditingIndex == index &&
                                    state.currentEditingType == IngredientType.ingredient;

                                if (shouldShow) {
                                  return _buildFullWidthSuggestionsList(
                                    isDarkMode,
                                    state.suggestions,
                                    state.currentEditingType,
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        );
                      }),

                      // 食材追加ボタン
                      _buildAddButton(
                        '食材を追加',
                        viewModel.addNewIngredientRow,
                        isDarkMode,
                      ),
                      const SizedBox(height: 40),

                      // 調味料セクション
                      _buildSectionTitle('調味料', isDarkMode),
                      const SizedBox(height: 12),

                      // 調味料入力フォーム
                      ...List.generate(state.seasoningNameControllers.length, (
                        index,
                      ) {
                        return Column(
                          children: [
                            _buildIngredientRow(index, isDarkMode, 'seasoning'),
                            // 候補表示（このフィールドが編集中の場合）
                            Builder(
                              builder: (context) {
                                final shouldShow =
                                    state.suggestions.isNotEmpty &&
                                    state.currentEditingIndex == index &&
                                    state.currentEditingType == IngredientType.seasoning;

                                if (shouldShow) {
                                  return _buildFullWidthSuggestionsList(
                                    isDarkMode,
                                    state.suggestions,
                                    state.currentEditingType,
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        );
                      }),

                      // 調味料追加ボタン
                      _buildAddButton(
                        '調味料を追加',
                        viewModel.addNewSeasoningRow,
                        isDarkMode,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
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
    final state = ref.watch(ingredientSelectionViewModelProvider);
    final viewModel = ref.watch(ingredientSelectionViewModelProvider.notifier);
    
    final nameControllers =
        type == 'seasoning' ? state.seasoningNameControllers : state.nameControllers;
    final amountControllers =
        type == 'seasoning' ? state.seasoningAmountControllers : state.amountControllers;
    final nameFocusNodes =
        type == 'seasoning' ? state.seasoningNameFocusNodes : state.nameFocusNodes;
    final amountFocusNodes =
        type == 'seasoning' ? state.seasoningAmountFocusNodes : state.amountFocusNodes;
    final hintText = type == 'seasoning' ? '調味料名' : '材料名';
    final ingredientType = type == 'seasoning' ? IngredientType.seasoning : IngredientType.ingredient;

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
                        fontSize: 20,
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
                        viewModel.onIngredientNameChanged(value, index, ingredientType);
                      },
                      onTap: () {
                        viewModel.onIngredientFieldTap(index, ingredientType);
                      },
                      onTapOutside: (event) {
                        viewModel.onIngredientFieldTapOutside(index, ingredientType);
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
                  fontSize: 20,
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
                            ? viewModel.removeSeasoningRow(index)
                            : viewModel.removeIngredientRow(index),
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

  Widget _buildFullWidthSuggestionsList(
    bool isDarkMode,
    List<Ingredient> suggestions,
    IngredientType currentEditingType,
  ) {
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
            currentEditingType == IngredientType.seasoning ? '候補の調味料' : '候補の食材',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // 候補リストをチップ形式で表示
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                suggestions.map((ingredient) {
                  return _buildIngredientSuggestionChip(ingredient, isDarkMode);
                }).toList(),
          ),
        ],
      ),
    );
  }


  Widget _buildIngredientSuggestionChip(
    Ingredient ingredient,
    bool isDarkMode,
  ) {
    final state = ref.watch(ingredientSelectionViewModelProvider);
    final viewModel = ref.watch(ingredientSelectionViewModelProvider.notifier);
    
    return GestureDetector(
      onTap: () {
        if (state.currentEditingIndex >= 0) {
          viewModel.selectIngredient(ingredient, state.currentEditingIndex);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: ingredient.backgroundColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ingredient.backgroundColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 材料の小さなアイコン
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: ingredient.backgroundColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  ingredient.iconPath,
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: ingredient.backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          ingredient.name.isNotEmpty
                              ? ingredient.name.substring(0, 1)
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // 材料名
            Text(
              ingredient.name,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
}
