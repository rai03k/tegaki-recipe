import 'package:flutter/material.dart';

/// 画面サイズに基づくレスポンシブサイズのextension
/// 基準横幅を375px（iPhone SE）として、現在の画面横幅に応じてスケールする
extension ResponsiveSize on num {
  /// 横幅ベースのレスポンシブサイズ（Width Proportional Unit）
  /// 使用例: 16.wpu → 画面横幅に応じた16pxサイズ
  double wpu(BuildContext context) {
    const baseWidth = 375.0; // 基準横幅（iPhone SE）
    final screenWidth = MediaQuery.of(context).size.width;
    return (this * screenWidth / baseWidth).toDouble();
  }

  /// 高さベースのレスポンシブサイズ（Height Proportional Unit）
  /// 使用例: 16.hpu → 画面高さに応じた16pxサイズ
  double hpu(BuildContext context) {
    const baseHeight = 667.0; // 基準高さ（iPhone SE）
    final screenHeight = MediaQuery.of(context).size.height;
    return (this * screenHeight / baseHeight).toDouble();
  }

  /// 最小サイズベースのレスポンシブサイズ（画面の横幅・高さの小さい方を基準）
  /// 使用例: 16.spu → 画面の小さい方の辺に応じた16pxサイズ
  double spu(BuildContext context) {
    const baseSize = 375.0; // 基準サイズ
    final screenSize = MediaQuery.of(context).size;
    final minSize = screenSize.width < screenSize.height 
        ? screenSize.width 
        : screenSize.height;
    return (this * minSize / baseSize).toDouble();
  }
}

/// MediaQueryを使わずにBuildContextから直接レスポンシブサイズを取得するヘルパー
class ResponsiveSizeHelper {
  static double getWpu(BuildContext context, num value) {
    return value.wpu(context);
  }

  static double getHpu(BuildContext context, num value) {
    return value.hpu(context);
  }

  static double getSpu(BuildContext context, num value) {
    return value.spu(context);
  }
}