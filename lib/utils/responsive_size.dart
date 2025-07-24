import 'package:flutter/material.dart';

/// 画面サイズに基づくレスポンシブサイズのextension
/// 基準サイズを375px（横幅）、667px（高さ）のiPhone SEとして、現在の画面サイズに応じてスケールする
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

/// 高さベース優先のレスポンシブサイズのextension（家具などのUI要素に推奨）
/// 基準高さを667px（iPhone SE）として、現在の画面高さに応じてスケールする
extension HeightBasedResponsiveSize on num {
  /// 高さベース優先のレスポンシブサイズ（Height-first Proportional Unit）
  /// 使用例: 50.hfpu(context) → 画面高さに応じた50px相当のサイズ
  double hfpu(BuildContext context) {
    const baseHeight = 667.0; // 基準高さ（iPhone SE）
    final screenHeight = MediaQuery.of(context).size.height;
    return (this * screenHeight / baseHeight).toDouble();
  }

  /// 高さベース（最小・最大制限付き）
  /// 使用例: 50.hfpuClamped(context, min: 30, max: 80)
  double hfpuClamped(BuildContext context, {double? min, double? max}) {
    final size = hfpu(context);
    if (min != null && max != null) {
      return size.clamp(min, max);
    } else if (min != null) {
      return size < min ? min : size;
    } else if (max != null) {
      return size > max ? max : size;
    }
    return size;
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