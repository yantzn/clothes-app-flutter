import 'package:flutter/material.dart';
import 'package:clothes_app/core/theme.dart';

class SceneDetailCard extends StatelessWidget {
  final String sceneName;
  final String comment;
  final List<String> items;
  final String? medicalNote;

  const SceneDetailCard({
    super.key,
    required this.sceneName,
    required this.comment,
    required this.items,
    this.medicalNote,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // 画面幅/親制約に応じてカードの横幅を拡張（サイズは固定）。
    const double horizontalMargin = 16.0; // 画面端の余白想定
    // 大画面向けのスケーリングは対象外（固定サイズ）
    const double iconSize = 24;
    const double imageHeight = 120;
    const double paddingAll = 20;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double containerWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final double maxCardWidth = (containerWidth - horizontalMargin * 2)
            .clamp(320.0, 1200.0);
        return Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: maxCardWidth,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0.8,
              child: Padding(
                padding: const EdgeInsets.all(paddingAll),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _sceneIcon(sceneName),
                          size: iconSize,
                          color: AppTheme.primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          sceneName,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      comment,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: imageHeight,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFFF7F9FB),
                        border: Border.all(color: const Color(0xFFE0E6EE)),
                      ),
                      child: const Center(
                        child: Text(
                          '服装イラスト（後で画像差し込み）',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '今日のおすすめ',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: items
                          .map(
                            (i) => Chip(
                              label: Text(i),
                              backgroundColor: AppTheme.primaryBlue.withValues(
                                alpha: 0.08,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 15),
                    if (medicalNote != null && medicalNote!.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 20,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              medicalNote!,
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _sceneIcon(String name) {
    if (name == '今日') return Icons.today_rounded;
    if (name.contains('室内')) return Icons.home_rounded;
    if (name.contains('おでかけ')) return Icons.directions_walk_rounded;
    return Icons.school_rounded;
  }
}
