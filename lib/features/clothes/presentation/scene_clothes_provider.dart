import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'clothes_providers.dart';

/// シーン別の服装アドバイス
final sceneClothesProvider = Provider<Map<String, List<String>>>((ref) {
  final clothes = ref.watch(todayClothesProvider).value;

  if (clothes == null) {
    return {
      "室内": ["読み込み中…"],
      "おでかけ": ["読み込み中…"],
      "公園遊び": ["読み込み中…"],
      "保育園": ["読み込み中…"],
    };
  }

  final temp = clothes.temperature.feelsLike;

  return {
    "室内": _buildIndoor(temp),
    "おでかけ": _buildOutdoor(temp),
    "公園遊び": _buildPark(temp),
    "保育園": _buildNursery(temp),
  };
});

//
// ---------------------------------------------------------
// 個別ロジック
// ---------------------------------------------------------

List<String> _buildIndoor(double t) {
  if (t < 10) return ["長袖Tシャツ", "裏起毛トレーナー", "暖かいズボン"];
  if (t < 18) return ["長袖Tシャツ", "薄手カーディガン"];
  return ["半袖Tシャツ", "薄手のズボン"];
}

List<String> _buildOutdoor(double t) {
  if (t < 5) return ["厚手コート", "ニット帽", "手袋"];
  if (t < 12) return ["パーカー", "ウィンドブレーカー", "長袖Tシャツ"];
  if (t < 18) return ["薄手パーカー", "長袖Tシャツ"];
  return ["半袖Tシャツ", "日よけ帽子"];
}

List<String> _buildPark(double t) {
  if (t < 10) return ["動きやすい厚手アウター", "長ズボン"];
  if (t < 18) return ["薄手パーカー", "動きやすい長ズボン"];
  return ["半袖Tシャツ", "ショートパンツ", "帽子"];
}

List<String> _buildNursery(double t) {
  if (t < 10) return ["長袖Tシャツ", "トレーナー", "長ズボン"];
  if (t < 18) return ["長袖Tシャツ", "薄手パーカー"];
  return ["半袖Tシャツ", "薄手ズボン"];
}
