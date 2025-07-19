import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_view_model.g.dart';

/// テーマ管理のNotifier
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() {
    return ThemeMode.light;
  }

  /// テーマを切り替える
  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  /// ライトテーマかどうかを判定
  bool get isLightMode => state == ThemeMode.light;

  /// ダークテーマかどうかを判定
  bool get isDarkMode => state == ThemeMode.dark;
}