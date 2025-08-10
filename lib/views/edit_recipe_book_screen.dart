import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../models/database.dart';
import '../services/image_service.dart';
import '../view_models/recipe_book_view_model.dart';
import '../view_models/theme_view_model.dart';
import 'dart:io';

class EditRecipeBookScreen extends ConsumerStatefulWidget {
  final RecipeBook recipeBook;

  const EditRecipeBookScreen({super.key, required this.recipeBook});

  @override
  ConsumerState<EditRecipeBookScreen> createState() =>
      _EditRecipeBookScreenState();
}

class _EditRecipeBookScreenState extends ConsumerState<EditRecipeBookScreen> {
  late final TextEditingController _titleController;
  final _imageService = ImageService();
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipeBook.title);
    _selectedImagePath = widget.recipeBook.coverImagePath;
  }

  @override
  void dispose() {
    _titleController.dispose();
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

  Future<void> _updateRecipeBook() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('タイトルを入力してください')));
      return;
    }

    final success = await ref
        .read(recipeBookNotifierProvider.notifier)
        .updateRecipeBook(
          id: widget.recipeBook.id,
          title: _titleController.text.trim(),
          coverImagePath: _selectedImagePath,
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('レシピ本を更新しました')));
        context.pop();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('エラーが発生しました')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeNotifierProvider) == ThemeMode.dark;
    final recipeBookState = ref.watch(recipeBookNotifierProvider);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      resizeToAvoidBottomInset: true, // キーボード対応
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 戻るボタン
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
                        'レシピ本編集',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // 表紙画像選択
                  Center(
                    child: GestureDetector(
                      onTap: _selectImage,
                      child: Container(
                        width: 200,
                        height: 200 * 4 / 3, // 3:4比率（縦長）を正確に計算
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
                                ? FutureBuilder<File>(
                                  future: ImageService.getImageFile(
                                    _selectedImagePath!,
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return FutureBuilder<bool>(
                                        future: snapshot.data!.exists(),
                                        builder: (context, existsSnapshot) {
                                          if (existsSnapshot.hasData &&
                                              existsSnapshot.data == true) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.file(
                                                snapshot.data!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return _buildImagePlaceholder(
                                                    isDarkMode,
                                                  );
                                                },
                                              ),
                                            );
                                          }
                                          return _buildImagePlaceholder(
                                            isDarkMode,
                                          );
                                        },
                                      );
                                    }
                                    return _buildImagePlaceholder(isDarkMode);
                                  },
                                )
                                : _buildImagePlaceholder(isDarkMode),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // タイトル入力
                  Text(
                    'レシピ本タイトル',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleController,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      hintText: 'レシピ本のタイトルを入力',
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              isDarkMode
                                  ? Colors.grey[600]!
                                  : Colors.grey[300]!,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              isDarkMode
                                  ? Colors.grey[600]!
                                  : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.deepPurple,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40), // Spacerの代わりに固定高さ
                  // 更新ボタン
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          recipeBookState.isLoading ? null : _updateRecipeBook,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          recipeBookState.isLoading
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
                              : const Text(
                                '更新',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 画像プレースホルダー
  Widget _buildImagePlaceholder(bool isDarkMode) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HugeIcon(
          icon: HugeIcons.strokeRoundedImage01,
          color: isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
          size: 48.0,
        ),
        const SizedBox(height: 8),
        Text(
          '表紙画像を選択',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
