import 'package:flutter/material.dart';
import 'package:clothes_app/core/widgets/choice_chip_row.dart';
import 'package:clothes_app/core/util/layout_utils.dart';
import 'package:clothes_app/features/clothes/presentation/scene_clothes_provider.dart';
import 'package:clothes_app/features/clothes/presentation/widgets/scene_detail_card.dart';

class SceneSection extends StatelessWidget {
  final List<SceneClothes> sceneList;
  final int selectedIndex;
  final ValueChanged<int> onSceneChanged;
  final double leadingInset; // セクション内の左インデント
  final double extraLeftShift; // 微調整用のシフト
  final double maxWidth;

  const SceneSection({
    super.key,
    required this.sceneList,
    required this.selectedIndex,
    required this.onSceneChanged,
    this.leadingInset = 0,
    this.extraLeftShift = 0,
    this.maxWidth = 480,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 画面幅に応じてセクション幅を拡張（横幅のみ可変、縦は固定）
    // 端の余白を考慮し、最小/最大幅をクランプ（320〜1200）
    final double widthConstraint = screenWidth <= 0
        ? 480.0
        : (screenWidth - 40.0).clamp(320.0, 1200.0);
    final scene = sceneList[selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox.shrink(),
        ChoiceChipRow(
          labels: sceneList.map((e) => e.scene).toList(),
          selectedIndex: selectedIndex,
          onChanged: onSceneChanged,
          iconBuilder: (label) => _iconForLabel(label),
          leadingInset: leadingInset,
          extraLeftShift: extraLeftShift,
          compact: true,
        ),
        const SizedBox(height: 16),
        Transform.translate(
          offset: Offset(extraLeftShift, 0),
          child: Padding(
            padding: EdgeInsets.only(left: leadingInset),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: widthConstraint),
              child: SceneDetailCard(
                sceneName: scene.scene,
                comment: scene.comment,
                items: scene.items,
                medicalNote: scene.medicalNote,
                notes: scene.notes,
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _sceneIcon(String name) {
    if (name.contains('室内')) return Icons.home_rounded;
    if (name.contains('おでかけ')) return Icons.directions_walk_rounded;
    return Icons.checkroom_outlined;
  }

  // ラベルから該当シーンを引き当て、ageGroupがあればそれに応じたアイコンにする
  IconData _iconForLabel(String label) {
    final SceneClothes s = sceneList.firstWhere(
      (e) => e.scene == label,
      orElse: () => const SceneClothes(scene: '', comment: '', items: []),
    );

    final String? ag = s.ageGroup;
    if (ag != null && ag.isNotEmpty) {
      return _ageGroupIcon(ag);
    }
    // 年齢層情報がない場合は従来のシーン名ベース
    return _sceneIcon(label);
  }

  // 年齢層に応じたアイコンの割り当て
  IconData _ageGroupIcon(String ageGroup) {
    final g = ageGroup.toLowerCase();
    if (g.contains('infant') || g.contains('baby')) {
      return Icons.child_care; // 乳幼児
    }
    if (g.contains('toddler')) {
      return Icons.escalator_warning; // 幼児
    }
    if (g.contains('child') || g.contains('kids')) {
      return Icons.child_care; // 子ども
    }
    if (g.contains('teen')) {
      return Icons.person_outline; // ティーン
    }
    if (g.contains('adult')) {
      return Icons.person; // 大人
    }
    // 不明な場合のフォールバック
    return Icons.person;
  }

  // 推奨のインデントプリセット
  static double indentToHeaderTitle() => LayoutUtils.indentForHeaderTitle();
  static double indentToHeaderIcon() => LayoutUtils.indentForHeaderIcon();
  static double nudgeLeftSmall() => LayoutUtils.nudgeLeftSmall();
}
