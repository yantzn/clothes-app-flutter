import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'clothes_providers.dart';

/// --------------------------------------------
/// シーン別服装のデータモデル
/// --------------------------------------------
class SceneClothes {
  final String scene;
  final String comment;
  final List<String> items;
  final String? medicalNote; // 追加

  const SceneClothes({
    required this.scene,
    required this.comment,
    required this.items,
    this.medicalNote,
  });
}

/// --------------------------------------------
/// シーン別服装アドバイス Provider
/// （室内 / おでかけ / 学校・保育園）
/// --------------------------------------------
final sceneClothesProvider = Provider<List<SceneClothes>>((ref) {
  final clothes = ref.watch(todayClothesProvider).value;

  // まだ服装データが取得できていない場合
  if (clothes == null) {
    return const [
      SceneClothes(scene: '室内', comment: '読み込み中…', items: ['…']),
      SceneClothes(scene: 'おでかけ', comment: '読み込み中…', items: ['…']),
      SceneClothes(scene: '学校・保育園', comment: '読み込み中…', items: ['…']),
    ];
  }

  final temp = clothes.temperature.feelsLike;

  return [
    SceneClothes(
      scene: '室内',
      comment: _indoorComment(temp),
      items: _buildIndoor(temp),
    ),
    SceneClothes(
      scene: 'おでかけ',
      comment: _outdoorComment(temp),
      items: _buildOutdoor(temp),
    ),
    SceneClothes(
      scene: '学校・保育園',
      comment: _nurseryComment(temp),
      items: _buildNursery(temp),
    ),
  ];
});

/// ---------------------------------------------------------
/// コメント（シーン説明）
/// ---------------------------------------------------------
String _indoorComment(double t) {
  if (t < 10) return '寒い日は暖かい室内でも保温が必要です';
  if (t < 18) return '室内では薄手の調節しやすい服が快適です';
  return '軽装で OK。動きやすさを重視しましょう';
}

String _outdoorComment(double t) {
  if (t < 5) return 'しっかり防寒して短時間の外出も安心に';
  if (t < 12) return 'パーカーや羽織りで調整しやすくしましょう';
  if (t < 18) return '軽い羽織りで快適に過ごせます';
  return '日よけ対策をしっかりしましょう';
}

String _nurseryComment(double t) {
  if (t < 10) return '外遊びに備えて動きやすい防寒が必要です';
  if (t < 18) return '薄手の長袖がちょうどよい季節です';
  return '動きやすい軽装で過ごしやすい気温です';
}

// ---------------------------------------------------------
// 推奨服装アイテム
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

List<String> _buildNursery(double t) {
  if (t < 10) return ["長袖Tシャツ", "トレーナー", "長ズボン"];
  if (t < 18) return ["長袖Tシャツ", "薄手パーカー"];
  return ["半袖Tシャツ", "薄手ズボン"];
}
