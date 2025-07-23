import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../view_models/theme_view_model.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeNotifierProvider) == ThemeMode.dark;
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

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
                    '設定',
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

              // 設定項目リスト
              Expanded(
                child: ListView(
                  children: [
                    // テーマ設定
                    _buildSettingItem(
                      icon:
                          isDarkMode
                              ? HugeIcons.strokeRoundedMoon02
                              : HugeIcons.strokeRoundedSun03,
                      title: 'テーマ',
                      subtitle: isDarkMode ? 'ダークモード' : 'ライトモード',
                      onTap: () => themeNotifier.toggleTheme(),
                      isDarkMode: isDarkMode,
                      trailing: Switch(
                        value: isDarkMode,
                        onChanged: (_) => themeNotifier.toggleTheme(),
                        activeColor: Colors.blue[400],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // アプリについて
                    _buildSettingItem(
                      icon: HugeIcons.strokeRoundedInformationCircle,
                      title: 'アプリについて',
                      subtitle: '手書きレシピアプリ v1.0.0',
                      onTap: () => _showAboutDialog(context, isDarkMode),
                      isDarkMode: isDarkMode,
                    ),

                    const SizedBox(height: 16),

                    // データ管理
                    _buildSettingItem(
                      icon: HugeIcons.strokeRoundedDatabase01,
                      title: 'データ管理',
                      subtitle: 'レシピデータのバックアップと復元',
                      onTap:
                          () => _showDataManagementDialog(context, isDarkMode),
                      isDarkMode: isDarkMode,
                    ),

                    const SizedBox(height: 16),

                    // フィードバック
                    _buildSettingItem(
                      icon: HugeIcons.strokeRoundedMessageNotification01,
                      title: 'フィードバック',
                      subtitle: '改善要望やバグレポートを送信',
                      onTap: () => _showFeedbackDialog(context, isDarkMode),
                      isDarkMode: isDarkMode,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDarkMode,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? Colors.blue[400]!.withOpacity(0.2)
                        : Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: HugeIcon(
                icon: icon,
                color: isDarkMode ? Colors.blue[400]! : Colors.blue[600]!,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'ArmedLemon',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'ArmedLemon',
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else
              HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                color: isDarkMode ? Colors.grey[400]! : Colors.grey[500]!,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
            title: Text(
              'アプリについて',
              style: TextStyle(
                fontFamily: 'ArmedLemon',
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            content: Text(
              '手書きレシピアプリ\nバージョン: 1.0.0\n\n温かみのある手書き風デザインで、\nあなたの大切なレシピを管理できます。',
              style: TextStyle(
                fontFamily: 'ArmedLemon',
                color: isDarkMode ? Colors.white70 : Colors.black87,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontFamily: 'ArmedLemon',
                    color: isDarkMode ? Colors.blue[400] : Colors.blue[600],
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showDataManagementDialog(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
            title: Text(
              'データ管理',
              style: TextStyle(
                fontFamily: 'ArmedLemon',
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            content: Text(
              'データのバックアップと復元機能は\n今後のアップデートで実装予定です。',
              style: TextStyle(
                fontFamily: 'ArmedLemon',
                color: isDarkMode ? Colors.white70 : Colors.black87,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontFamily: 'ArmedLemon',
                    color: isDarkMode ? Colors.blue[400] : Colors.blue[600],
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showFeedbackDialog(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
            title: Text(
              'フィードバック',
              style: TextStyle(
                fontFamily: 'ArmedLemon',
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            content: Text(
              'ご意見・ご要望がございましたら、\nアプリストアのレビューまたは\n開発者へお気軽にご連絡ください！',
              style: TextStyle(
                fontFamily: 'ArmedLemon',
                color: isDarkMode ? Colors.white70 : Colors.black87,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontFamily: 'ArmedLemon',
                    color: isDarkMode ? Colors.blue[400] : Colors.blue[600],
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
