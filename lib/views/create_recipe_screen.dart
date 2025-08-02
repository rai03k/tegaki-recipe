import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import '../models/database.dart';
import '../models/ingredient.dart';
import '../services/image_service.dart';
import '../services/database_service.dart';
import '../view_models/recipe_view_model.dart';
import '../view_models/theme_view_model.dart';
import 'dart:io';

class CreateRecipeScreen extends ConsumerStatefulWidget {
  final RecipeBook recipeBook;
  final Recipe? existingRecipe; // 編集モード用の既存レシピ

  const CreateRecipeScreen({
    super.key, 
    required this.recipeBook,
    this.existingRecipe,
  });

  @override
  ConsumerState<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends ConsumerState<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  final _memoController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _referenceUrlController = TextEditingController();
  final _imageService = ImageService();

  String? _selectedImagePath;
  List<RecipeIngredient> _selectedIngredients = [];

  // 編集モードかどうかを判定
  bool get isEditMode => widget.existingRecipe != null;

  @override
  void initState() {
    super.initState();
    _initializeExistingData();
  }

  // 既存レシピのデータを初期値として設定
  void _initializeExistingData() {
    if (widget.existingRecipe != null) {
      final recipe = widget.existingRecipe!;
      _titleController.text = recipe.title;
      _selectedImagePath = recipe.imagePath;
      _cookingTimeController.text = recipe.cookingTimeMinutes?.toString() ?? '';
      _memoController.text = recipe.memo ?? '';
      _instructionsController.text = recipe.instructions ?? '';
      _referenceUrlController.text = recipe.referenceUrl ?? '';
      
      // 材料データは後で非同期で読み込む
      _loadExistingIngredients();
    }
  }

  // 既存の材料を読み込む
  Future<void> _loadExistingIngredients() async {
    if (widget.existingRecipe != null) {
      try {
        final database = DatabaseService.instance.database;
        final ingredients = await (database.select(database.ingredients)
              ..where((tbl) => tbl.recipeId.equals(widget.existingRecipe!.id))
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
            .get();

        // Ingredient を RecipeIngredient に変換
        final recipeIngredients = ingredients.map((ingredient) {
          // 定義済み材料から追加情報を取得
          final predefinedIngredient = IngredientData.predefinedIngredients
              .where((item) => item.name == ingredient.name)
              .firstOrNull;

          return RecipeIngredient(
            name: ingredient.name,
            amount: ingredient.amount ?? '',
            iconPath: predefinedIngredient?.iconPath,
            backgroundColor: predefinedIngredient?.backgroundColor,
          );
        }).toList();

        setState(() {
          _selectedIngredients = recipeIngredients;
        });
      } catch (e) {
        print('材料の読み込みに失敗しました: $e');
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cookingTimeController.dispose();
    _memoController.dispose();
    _instructionsController.dispose();
    _referenceUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final isDarkMode = ref.read(themeNotifierProvider) == ThemeMode.dark;
    final imagePath = await _imageService.pickAndCropRecipeImage(
      context: context,
      isDarkMode: isDarkMode,
    );

    if (imagePath != null) {
      setState(() {
        _selectedImagePath = imagePath;
      });
    }
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('料理名を入力してください')));
      return;
    }

    // 所要時間を分に変換
    int? cookingTimeMinutes;
    if (_cookingTimeController.text.trim().isNotEmpty) {
      cookingTimeMinutes = int.tryParse(_cookingTimeController.text.trim());
    }

    bool success;
    if (isEditMode) {
      // 編集モード：更新処理
      success = await ref
          .read(recipeNotifierProvider.notifier)
          .updateRecipe(
            id: widget.existingRecipe!.id,
            title: _titleController.text.trim(),
            imagePath: _selectedImagePath,
            cookingTimeMinutes: cookingTimeMinutes,
            memo:
                _memoController.text.trim().isNotEmpty
                    ? _memoController.text.trim()
                    : null,
            instructions:
                _instructionsController.text.trim().isNotEmpty
                    ? _instructionsController.text.trim()
                    : null,
            referenceUrl:
                _referenceUrlController.text.trim().isNotEmpty
                    ? _referenceUrlController.text.trim()
                    : null,
            ingredients: _selectedIngredients.isNotEmpty ? _selectedIngredients : null,
          );
    } else {
      // 作成モード：新規作成処理
      success = await ref
          .read(recipeNotifierProvider.notifier)
          .createRecipe(
            recipeBookId: widget.recipeBook.id,
            title: _titleController.text.trim(),
            imagePath: _selectedImagePath,
            cookingTimeMinutes: cookingTimeMinutes,
            memo:
                _memoController.text.trim().isNotEmpty
                    ? _memoController.text.trim()
                    : null,
            instructions:
                _instructionsController.text.trim().isNotEmpty
                    ? _instructionsController.text.trim()
                    : null,
            referenceUrl:
                _referenceUrlController.text.trim().isNotEmpty
                    ? _referenceUrlController.text.trim()
                    : null,
            ingredients: _selectedIngredients.isNotEmpty ? _selectedIngredients : null,
          );
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(
          content: Text(isEditMode ? 'レシピを更新しました' : 'レシピを作成しました')));
        context.pop(success); // 成功時にtrueを返す
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(
          content: Text(isEditMode ? 'レシピの更新に失敗しました' : 'レシピの作成に失敗しました')));
      }
    }
  }

  Future<void> _launchUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('URLを開けませんでした')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('無効なURLです')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeNotifierProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      body: SafeArea(
        child: Form(
          key: _formKey,
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
                      isEditMode ? 'レシピ編集' : 'レシピ作成',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // スクロール可能なコンテンツ
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 料理画像選択
                      GestureDetector(
                        onTap: _selectImage,
                        child: Container(
                          width: double.infinity,
                          height:
                              (MediaQuery.of(context).size.width - 40) *
                              3 /
                              4, // 4:3比率
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[800] : Colors.white,
                            border: Border.all(
                              color:
                                  isDarkMode
                                      ? Colors.grey[600]!
                                      : Colors.grey[300]!,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              _selectedImagePath != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(_selectedImagePath!),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  )
                                  : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedImage01,
                                        color:
                                            isDarkMode
                                                ? Colors.grey[400]!
                                                : Colors.grey[600]!,
                                        size: 48.0,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        '料理画像を選択',
                                        style: TextStyle(
                                          color:
                                              isDarkMode
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ノート風セクション（料理名以下）
                      _buildNotePaperSection(isDarkMode),
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

  Widget _buildNotePaperSection(bool isDarkMode) {
    final recipeState = ref.watch(recipeNotifierProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: NotePaperPainter(
            lineColor:
                isDarkMode
                    ? Colors.grey[700]!.withValues(alpha: 0.3)
                    : Colors.grey[300]!.withValues(alpha: 0.5),
            lineSpacing: 40.0,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 料理名
                _buildSectionTitle('料理名', isDarkMode, required: true),
                _buildTextField(
                  controller: _titleController,
                  hintText: '料理名を入力してください',
                  isDarkMode: isDarkMode,
                  // validator: (value) {
                  //   if (value == null || value.trim().isEmpty) {
                  //     return '料理名を入力してください';
                  //   }
                  //   return null;
                  // },
                ),
                const SizedBox(height: 32),

                // 所要時間
                _buildSectionTitle('所要時間', isDarkMode),
                _buildTextField(
                  controller: _cookingTimeController,
                  hintText: '調理時間を入力（分）',
                  isDarkMode: isDarkMode,
                  keyboardType: TextInputType.number,
                  suffixText: '分',
                ),
                const SizedBox(height: 32),

                // メモ
                _buildSectionTitle('メモ', isDarkMode),
                const SizedBox(height: 4),
                _buildTextField(
                  controller: _memoController,
                  hintText: 'メモを入力してください',
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 32),

                // 材料
                _buildSectionTitle('材料', isDarkMode),
                const SizedBox(height: 8),
                _buildIngredientsSection(isDarkMode),
                const SizedBox(height: 54),

                // 作り方
                _buildSectionTitle('作り方', isDarkMode),
                _buildTextField(
                  controller: _instructionsController,
                  hintText: '作り方を入力してください',
                  isDarkMode: isDarkMode,
                  maxLines: 5,
                ),
                const SizedBox(height: 42),

                // 参考URL
                _buildSectionTitle('参考URL', isDarkMode),
                _buildTextField(
                  controller: _referenceUrlController,
                  hintText: '参考URLを入力してください',
                  isDarkMode: isDarkMode,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 32),

                // 保存ボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: recipeState.isLoading ? null : _saveRecipe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        recipeState.isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              isEditMode ? '更新' : '作成',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIngredientsSection(bool isDarkMode) {
    return Column(
      children: [
        // 材料追加ボタン
        GestureDetector(
          onTap: () async {
            final result = await context.push(
              '/ingredient-selection', 
              extra: _selectedIngredients.isEmpty ? null : _selectedIngredients,
            );
            if (result != null && result is List<RecipeIngredient>) {
              setState(() {
                _selectedIngredients = result;
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isDarkMode
                        ? Colors.grey[600]!.withValues(alpha: 0.3)
                        : Colors.grey[400]!.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedAdd01,
                  color: Colors.deepPurple,
                  size: 20.0,
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedIngredients.isEmpty 
                    ? '材料を選択' 
                    : '材料を選択 (${_selectedIngredients.length}個選択済み)',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 選択された材料一覧
        if (_selectedIngredients.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? Colors.grey[800]!.withValues(alpha: 0.3)
                      : Colors.grey[100]!.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '選択された材料（${_selectedIngredients.length}個）',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(_selectedIngredients.length, (index) {
                  final ingredient = _selectedIngredients[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        // 材料画像と色付きバッジ
                        if (ingredient.iconPath != null ||
                            ingredient.backgroundColor != null)
                          Stack(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child:
                                    ingredient.iconPath != null
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.asset(
                                            ingredient.iconPath!,
                                            width: 24,
                                            height: 24,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              // 画像が見つからない場合はテキストで代替
                                              return Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color:
                                                      ingredient
                                                          .backgroundColor ??
                                                      Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    ingredient.name.substring(
                                                      0,
                                                      1,
                                                    ),
                                                    style: const TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                        : Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: ingredient.backgroundColor,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              ingredient.name.substring(0, 1),
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                              ),
                              // 色付きバッジ（右下）
                              if (ingredient.backgroundColor != null)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: ingredient.backgroundColor,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color:
                                            isDarkMode
                                                ? Colors.grey[800]!
                                                : Colors.white,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        if (ingredient.iconPath != null ||
                            ingredient.backgroundColor != null)
                          const SizedBox(width: 8),

                        // 材料名と分量
                        Expanded(
                          child: Text(
                            '${ingredient.name}...${ingredient.amount}',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(
    String title,
    bool isDarkMode, {
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 2),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          if (required)
            Text(
              ' *',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isDarkMode,
    TextInputType? keyboardType,
    int? maxLines,
    String? suffixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      validator: validator,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
        fontSize: 18,
        height: maxLines != null ? 2.1 : null,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        suffixText: suffixText,
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        filled: true,
        fillColor: Colors.transparent, // 背景を透明にして横線を見せる
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
      onChanged: (value) {
        // 参考URLの変更を監視してリンク表示を更新
        if (controller == _referenceUrlController) {
          setState(() {});
        }
      },
    );
  }
}

// ノート風横線背景を描画するCustomPainter
class NotePaperPainter extends CustomPainter {
  final Color lineColor;
  final double lineSpacing;
  final double lineHeight;

  NotePaperPainter({
    required this.lineColor,
    this.lineSpacing = 40.0,
    this.lineHeight = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = lineColor
          ..strokeWidth = lineHeight
          ..style = PaintingStyle.stroke;

    // 横線を描画（コンテンツの高さに応じて動的に調整）
    for (double y = lineSpacing; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is NotePaperPainter) {
      return lineColor != oldDelegate.lineColor ||
          lineSpacing != oldDelegate.lineSpacing ||
          lineHeight != oldDelegate.lineHeight;
    }
    return true;
  }
}
