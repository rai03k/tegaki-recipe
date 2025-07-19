import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../services/image_service.dart';
import '../view_models/recipe_book_view_model.dart';
import '../view_models/theme_view_model.dart';
import '../constants/app_strings.dart';
import '../constants/ui_constants.dart';
import 'dart:io';

class CreateRecipeBookScreen extends ConsumerStatefulWidget {
  const CreateRecipeBookScreen({super.key});

  @override
  ConsumerState<CreateRecipeBookScreen> createState() => _CreateRecipeBookScreenState();
}

class _CreateRecipeBookScreenState extends ConsumerState<CreateRecipeBookScreen> {
  final _titleController = TextEditingController();
  final _imageService = ImageService();
  String? _selectedImagePath;

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

  Future<void> _saveRecipeBook() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.titleRequired)),
      );
      return;
    }

    final success = await ref.read(recipeBookNotifierProvider.notifier).createRecipeBook(
      title: _titleController.text.trim(),
      coverImagePath: _selectedImagePath,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.recipeBookCreated)),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.errorOccurred)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeNotifierProvider) == ThemeMode.dark;
    final recipeBookState = ref.watch(recipeBookNotifierProvider);
    
    return Scaffold(
      backgroundColor: isDarkMode ? Color(ColorConstants.grey900) : Color(ColorConstants.grey100),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(UIConstants.paddingLarge),
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
                      size: UIConstants.iconSizeSmall,
                    ),
                  ),
                  SizedBox(width: UIConstants.paddingMedium),
                  Text(
                    AppStrings.createRecipeBook,
                    style: TextStyle(
                      fontSize: UIConstants.fontSizeXLarge,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: UIConstants.paddingXLarge),

              // 表紙画像選択
              Center(
                child: GestureDetector(
                  onTap: _selectImage,
                  child: Container(
                    width: UIConstants.recipeBookWidth,
                    height: UIConstants.recipeBookHeight,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Color(ColorConstants.grey800) : Colors.white,
                      border: Border.all(
                        color: isDarkMode
                            ? Color(ColorConstants.grey600)
                            : Color(ColorConstants.grey300),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
                    ),
                    child: _selectedImagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
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
                                color: isDarkMode
                                    ? Color(ColorConstants.grey400)
                                    : Color(ColorConstants.grey600),
                                size: UIConstants.iconSizeMedium,
                              ),
                              SizedBox(height: UIConstants.paddingSmall),
                              Text(
                                AppStrings.selectCoverImage,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Color(ColorConstants.grey400)
                                      : Color(ColorConstants.grey600),
                                  fontSize: UIConstants.fontSizeMedium,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              SizedBox(height: UIConstants.paddingXLarge),

              // タイトル入力
              Text(
                AppStrings.recipeBookTitle,
                style: TextStyle(
                  fontSize: UIConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: UIConstants.paddingSmall),
              TextField(
                controller: _titleController,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: UIConstants.fontSizeMedium,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.enterRecipeBookTitle,
                  hintStyle: TextStyle(
                    color: isDarkMode ? Color(ColorConstants.grey400) : Color(ColorConstants.grey600),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Color(ColorConstants.grey800) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
                    borderSide: BorderSide(
                      color: isDarkMode
                          ? Color(ColorConstants.grey600)
                          : Color(ColorConstants.grey300),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
                    borderSide: BorderSide(
                      color: isDarkMode
                          ? Color(ColorConstants.grey600)
                          : Color(ColorConstants.grey300),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
                    borderSide: const BorderSide(
                      color: Colors.deepPurple,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // 保存ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: recipeBookState.isLoading ? null : _saveRecipeBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: UIConstants.paddingMedium),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
                    ),
                  ),
                  child: recipeBookState.isLoading
                      ? SizedBox(
                          height: UIConstants.paddingLarge,
                          width: UIConstants.paddingLarge,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          AppStrings.create,
                          style: TextStyle(
                            fontSize: UIConstants.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}