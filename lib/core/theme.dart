import 'package:flutter/material.dart';

/// アプリの統一テーマ（白×水色ベースのミニマルデザイン）
///
/// - Material 3
/// - 優しい色味
/// - 角丸カード
/// - AppBar は白背景に黒文字
/// - Chip は淡い水色
/// - ElevatedButton はアクセントカラー
///
class AppTheme {
  // -----------------------------------------------------
  // ■ 色定義（どこからでも参照される）
  // -----------------------------------------------------

  /// メインカラー（水色）
  static const primaryBlue = Color(0xFF3AAFD9);

  /// 明るいブルー（アクセント）
  static const lightBlue = Color(0xFF6DB4F5);

  /// 画面全体の背景
  static const surfaceLight = Color(0xFFF9FAFB);

  /// テキスト濃
  static const textDark = Color(0xFF374151);

  /// テキスト薄
  static const textLight = Color(0xFF6B7280);

  /// セクション背景（Home の青い帯）
  static const sectionBg = Color(0xFFF3F9FD);

  /// チップ背景色（ClothesDetailPage など）
  static const chipBg = Color(0xFFE6F4FF);

  // -----------------------------------------------------
  // ■ テーマ本体
  // -----------------------------------------------------
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // ----------------------------------------
    // カラースキーム
    // ----------------------------------------
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
      primary: primaryBlue,
      secondary: lightBlue,
      surface: Colors.white,
      background: surfaceLight,
    ),

    // ----------------------------------------
    // AppBar デザイン
    // ----------------------------------------
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),

    // ----------------------------------------
    // カード
    // ----------------------------------------
    cardTheme: CardThemeData(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFE7EDF3), width: 1),
      ),
    ),

    // ----------------------------------------
    // ElevatedButton（活性 / 非活性 状態つき）
    // ----------------------------------------
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevation: WidgetStateProperty.all(1),

        // ★ 状態に応じて色を変更：Enabled → primaryBlue / Disabled → Gray
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey.shade400; // 非活性
          }
          return primaryBlue; // 活性
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.white70; // 非活性テキスト
          }
          return Colors.white; // 活性テキスト
        }),
      ),
    ),

    // ----------------------------------------
    // TextButton
    // ----------------------------------------
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(foregroundColor: WidgetStateProperty.all(primaryBlue)),
    ),

    // ----------------------------------------
    // TextField
    // ----------------------------------------
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryBlue, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      labelStyle: TextStyle(fontSize: 14),
    ),

    // ----------------------------------------
    // Chip
    // ----------------------------------------
    chipTheme: ChipThemeData(
      backgroundColor: chipBg,
      selectedColor: primaryBlue.withOpacity(0.15),
      labelStyle: const TextStyle(color: textDark, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide.none,
    ),

    // ----------------------------------------
    // テキストテーマ
    // ----------------------------------------
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      bodyMedium: TextStyle(fontSize: 15, color: textDark),
      bodySmall: TextStyle(fontSize: 13, color: textLight),
    ),

    // ----------------------------------------
    // ListTile（設定画面など）
    // ----------------------------------------
    listTileTheme: const ListTileThemeData(
      iconColor: primaryBlue,
      titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      subtitleTextStyle: TextStyle(fontSize: 13, color: textLight),
    ),

    scaffoldBackgroundColor: surfaceLight,
  );
}
