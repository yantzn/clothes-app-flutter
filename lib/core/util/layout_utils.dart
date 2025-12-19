class LayoutUtils {
  static const double sectionHorizontalPadding = 20.0;
  static const double headerIconSize = 20.0;
  static const double headerIconGap = 8.0;

  // タイトル文字列の左端に揃える場合のインデント量（セクション内基準）
  static double indentForHeaderTitle() => headerIconSize + headerIconGap; // 28

  // 見出しアイコンの左端に揃える場合（セクション内基準）
  static double indentForHeaderIcon() => 0.0;

  // 微調整用：タグやカードをわずかに左へシフト（セクションのpadding内での見た目合わせ）
  static double nudgeLeftSmall() => -8.0;
  static double nudgeNone() => 0.0;
}
