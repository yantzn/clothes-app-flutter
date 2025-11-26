import 'package:flutter/material.dart';
import '../../../core/theme.dart';

/// 横スクロール用のシーン別服装カード
class SceneSuggestionCard extends StatelessWidget {
  final String sceneName; // 例: 室内
  final String icon; // 例: 🏠
  final List<String> suggestions; // 例: ["長袖Tシャツ", "薄手カーディガン"]

  const SceneSuggestionCard({
    super.key,
    required this.sceneName,
    required this.icon,
    required this.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7EDF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // アイコン + タイトル
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                sceneName,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // チップ群
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: suggestions
                .map(
                  (s) => Chip(
                    label: Text(s),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                    labelStyle: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: const Color(0xFFE6F4FF),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
