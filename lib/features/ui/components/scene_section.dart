import 'package:flutter/material.dart';
import 'choice_chip_row.dart';
import 'scene_detail_card.dart';
import 'layout_utils.dart';
import '../../clothes/presentation/scene_clothes_provider.dart';
import '../../../core/theme.dart';

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
    // 大画面の拡張は対象外: 最大幅は常に 480（ただし最小は 280）
    final double effectiveMaxWidth = 480.0;
    final double widthConstraint = screenWidth <= 0
        ? effectiveMaxWidth
        : ((screenWidth - 40).clamp(280.0, effectiveMaxWidth) as double);
    final scene = sceneList[selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox.shrink(),
        ChoiceChipRow(
          labels: sceneList.map((e) => e.scene).toList(),
          selectedIndex: selectedIndex,
          onChanged: onSceneChanged,
          iconBuilder: (label) => _sceneIcon(label),
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

  // 推奨のインデントプリセット
  static double indentToHeaderTitle() => LayoutUtils.indentForHeaderTitle();
  static double indentToHeaderIcon() => LayoutUtils.indentForHeaderIcon();
  static double nudgeLeftSmall() => LayoutUtils.nudgeLeftSmall();
}
