/// --------------------------------------------
/// シーン別服装のデータモデル
/// --------------------------------------------
class SceneClothes {
  final String scene;
  final String comment;
  final List<String> items;
  final String? medicalNote; // 追加
  final List<String>? notes; // Homeのsuggestion.notes
  final String? ageGroup; // 年齢層（icon切替用）

  const SceneClothes({
    required this.scene,
    required this.comment,
    required this.items,
    this.medicalNote,
    this.notes,
    this.ageGroup,
  });
}
