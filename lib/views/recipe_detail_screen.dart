import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/database.dart';
import '../view_models/theme_view_model.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final Recipe recipe;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeNotifierProvider) == ThemeMode.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: isTablet ? _buildTabletLayout(context, isDarkMode) : _buildPhoneLayout(context, isDarkMode),
      ),
    );
  }

  // スマホ（縦1カラム）レイアウト
  Widget _buildPhoneLayout(BuildContext context, bool isDarkMode) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 戻るボタン
            _buildBackButton(context, isDarkMode),
            
            const SizedBox(height: 20),
            
            // 料理画像
            _buildRecipeImage(),
            
            const SizedBox(height: 20),
            
            // 料理名
            _buildRecipeTitle(isDarkMode),
            
            const SizedBox(height: 10),
            
            // 所要時間
            _buildCookingTime(isDarkMode),
            
            const SizedBox(height: 15),
            
            // メモ
            if (recipe.memo.isNotEmpty) ...[
              _buildMemo(isDarkMode),
              const SizedBox(height: 20),
            ],
            
            // 材料
            _buildIngredientsSection(isDarkMode),
            
            const SizedBox(height: 20),
            
            // 作り方
            _buildInstructionsSection(isDarkMode),
            
            const SizedBox(height: 20),
            
            // 参考URL
            if (recipe.referenceUrl.isNotEmpty) ...[
              _buildReferenceUrl(isDarkMode),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  // タブレット（横2カラム）レイアウト
  Widget _buildTabletLayout(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // 戻るボタン
          Row(
            children: [
              _buildBackButton(context, isDarkMode),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // タイトルと所要時間
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecipeTitle(isDarkMode),
              const SizedBox(height: 10),
              _buildCookingTime(isDarkMode),
              if (recipe.memo.isNotEmpty) ...[
                const SizedBox(height: 15),
                _buildMemo(isDarkMode),
              ],
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 2カラムレイアウト
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左カラム: 画像・材料
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRecipeImage(),
                      const SizedBox(height: 20),
                      _buildIngredientsSection(isDarkMode),
                    ],
                  ),
                ),
                
                const SizedBox(width: 30),
                
                // 右カラム: 作り方・参考URL
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInstructionsSection(isDarkMode),
                      if (recipe.referenceUrl.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildReferenceUrl(isDarkMode),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDarkMode) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white24 : Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedArrowLeft01,
          color: isDarkMode ? Colors.white : Colors.black,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildRecipeImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: recipe.imagePath.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                recipe.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              ),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: Center(
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedImage01,
          color: Colors.grey[500]!,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildRecipeTitle(bool isDarkMode) {
    return Text(
      recipe.name,
      style: TextStyle(
        fontFamily: 'ArmedLemon',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : Colors.black,
        height: 1.2,
      ),
    );
  }

  Widget _buildCookingTime(bool isDarkMode) {
    return Row(
      children: [
        HugeIcon(
          icon: HugeIcons.strokeRoundedClock03,
          color: isDarkMode ? Colors.white70 : Colors.black54,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          '${recipe.cookingTime}分',
          style: TextStyle(
            fontFamily: 'ArmedLemon',
            fontSize: 18,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildMemo(bool isDarkMode) {
    return Text(
      recipe.memo,
      style: TextStyle(
        fontFamily: 'ArmedLemon',
        fontSize: 14,
        color: isDarkMode ? Colors.white60 : Colors.black45,
        height: 1.4,
      ),
    );
  }

  Widget _buildIngredientsSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF9BB8D3), // 青い背景色
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '材料（1人分）',
            style: TextStyle(
              fontFamily: 'ArmedLemon',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 材料リスト
        ...recipe.ingredients.map((ingredient) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(
                '• ',
                style: TextStyle(
                  fontFamily: 'ArmedLemon',
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Expanded(
                child: Text(
                  '${ingredient.name}　${ingredient.amount}',
                  style: TextStyle(
                    fontFamily: 'ArmedLemon',
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildInstructionsSection(bool isDarkMode) {
    final instructions = recipe.instructions.split('\n');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF9BB8D3), // 青い背景色
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '作り方',
            style: TextStyle(
              fontFamily: 'ArmedLemon',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 作り方リスト
        ...instructions.asMap().entries.map((entry) {
          final index = entry.key;
          final instruction = entry.value.trim();
          
          if (instruction.isEmpty) return const SizedBox.shrink();
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ',
                  style: TextStyle(
                    fontFamily: 'ArmedLemon',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Expanded(
                  child: Text(
                    instruction,
                    style: TextStyle(
                      fontFamily: 'ArmedLemon',
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildReferenceUrl(bool isDarkMode) {
    return GestureDetector(
      onTap: () => _launchUrl(recipe.referenceUrl),
      child: Text(
        recipe.referenceUrl,
        style: TextStyle(
          fontFamily: 'ArmedLemon',
          fontSize: 14,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}