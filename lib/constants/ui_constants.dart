/// UI関連の定数を管理するクラス
class UIConstants {
  // カルーセル関連
  static const double carouselViewportFraction = 0.5;
  static const double cardHeightRatio = 1.0 / 3.0;
  static const double carouselScaleReduction = 0.2;
  static const double minCarouselScale = 0.8;
  static const double maxCarouselScale = 1.0;
  
  // レシピ本関連
  static const double recipeBookWidth = 200.0;
  static const double recipeBookHeight = 267.0; // 3:4比率
  static const double aspectRatio3to4 = 3.0 / 4.0;
  
  // アイコンサイズ
  static const double iconSizeLarge = 80.0;
  static const double iconSizeMedium = 48.0;
  static const double iconSizeSmall = 24.0;
  
  // パディング・マージン
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 20.0;
  static const double paddingXLarge = 40.0;
  
  // ボーダーラジアス
  static const double borderRadiusSmall = 6.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  
  // フォントサイズ
  static const double fontSizeSmall = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 24.0;
  static const double fontSizeXXLarge = 26.0;
  
  // アニメーション
  static const Duration animationDurationFast = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  
  // 影
  static const double shadowBlurRadius = 8.0;
  static const double shadowSpreadRadius = 1.0;
  static const shadowOffsetDx = 0.0;
  static const shadowOffsetDy = 4.0;
  
  // その他
  static const double lampHangingRodWidth = 1.0;
  static const double lampHangingRodHeight = 60.0;
  static const double lampHeight = 70.0;
  static const double clockHeight = 100.0;
  
  // レイアウト位置
  static const double lampTopPosition = 40.0;
  static const double lampRightPosition = 30.0;
  static const double clockTopPosition = 70.0;
  static const double clockLeftPosition = 40.0;
}

/// 色関連の定数
class ColorConstants {
  // グレーパレット
  static const int grey100 = 0xFFF5F5F5;
  static const int grey200 = 0xFFEEEEEE;
  static const int grey300 = 0xFFE0E0E0;
  static const int grey400 = 0xFFBDBDBD;
  static const int grey600 = 0xFF757575;
  static const int grey700 = 0xFF616161;
  static const int grey800 = 0xFF424242;
  static const int grey900 = 0xFF212121;
  
  // 透明度
  static const double opacityLight = 0.1;
  static const double opacityMedium = 0.3;
  static const double opacityHigh = 0.6;
  static const double opacityFull = 1.0;
}