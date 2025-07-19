import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/database.dart';
import '../services/image_service.dart';
import '../view_models/recipe_view_model.dart';
import '../view_models/theme_view_model.dart';
import 'dart:io';

class CreateRecipeScreen extends ConsumerStatefulWidget {
  final RecipeBook recipeBook;

  const CreateRecipeScreen({
    super.key,
    required this.recipeBook,
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
  final List<String> _ingredients = []; // 仮実装：後で材料選択機能に置き換え

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
    final imagePath = await _imageService.pickAndCropImage(
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('料理名を入力してください')),
      );
      return;
    }

    // 所要時間を分に変換
    int? cookingTimeMinutes;
    if (_cookingTimeController.text.trim().isNotEmpty) {
      cookingTimeMinutes = int.tryParse(_cookingTimeController.text.trim());
    }

    final success = await ref.read(recipeNotifierProvider.notifier).createRecipe(
      recipeBookId: widget.recipeBook.id,
      title: _titleController.text.trim(),
      imagePath: _selectedImagePath,
      cookingTimeMinutes: cookingTimeMinutes,
      memo: _memoController.text.trim().isNotEmpty ? _memoController.text.trim() : null,
      instructions: _instructionsController.text.trim().isNotEmpty ? _instructionsController.text.trim() : null,
      referenceUrl: _referenceUrlController.text.trim().isNotEmpty ? _referenceUrlController.text.trim() : null,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('レシピを作成しました')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('レシピの作成に失敗しました')),
        );
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('URLを開けませんでした')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('無効なURLです')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeNotifierProvider) == ThemeMode.dark;
    final recipeState = ref.watch(recipeNotifierProvider);

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
                      'レシピ作成',
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
                      Center(
                        child: GestureDetector(
                          onTap: _selectImage,
                          child: Container(
                            width: 200,
                            height: 267, // 3:4比率
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.grey[800] : Colors.white,
                              border: Border.all(
                                color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _selectedImagePath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(_selectedImagePath!),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedImage01,
                                        color: isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
                                        size: 48.0,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '料理画像を選択',
                                        style: TextStyle(
                                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 料理名
                      _buildSectionTitle('料理名', isDarkMode, required: true),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _titleController,
                        hintText: '料理名を入力してください',
                        isDarkMode: isDarkMode,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '料理名を入力してください';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // 所要時間
                      _buildSectionTitle('所要時間', isDarkMode),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _cookingTimeController,
                        hintText: '調理時間を入力（分）',
                        isDarkMode: isDarkMode,
                        keyboardType: TextInputType.number,
                        suffixText: '分',
                      ),
                      const SizedBox(height: 24),

                      // メモ
                      _buildSectionTitle('メモ', isDarkMode),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _memoController,
                        hintText: 'メモを入力してください',
                        isDarkMode: isDarkMode,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      // 材料（仮実装）
                      _buildSectionTitle('材料', isDarkMode),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedAdd01,
                                  color: Colors.deepPurple,
                                  size: 20.0,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '材料を選択',
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            if (_ingredients.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '※材料選択機能は後で実装予定',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 作り方
                      _buildSectionTitle('作り方', isDarkMode),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _instructionsController,
                        hintText: '作り方を入力してください',
                        isDarkMode: isDarkMode,
                        maxLines: 6,
                      ),
                      const SizedBox(height: 24),

                      // 参考URL
                      _buildSectionTitle('参考URL', isDarkMode),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _referenceUrlController,
                        hintText: '参考URLを入力してください',
                        isDarkMode: isDarkMode,
                        keyboardType: TextInputType.url,
                      ),
                      if (_referenceUrlController.text.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: GestureDetector(
                            onTap: () => _launchUrl(_referenceUrlController.text.trim()),
                            child: Text(
                              _referenceUrlController.text.trim(),
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
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
                          child: recipeState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  '作成',
                                  style: TextStyle(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode, {bool required = false}) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        if (required)
          Text(
            ' *',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
      ],
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
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        suffixText: suffixText,
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.deepPurple,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
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