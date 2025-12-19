import 'package:flutter/material.dart';
import 'package:clothes_app/core/theme.dart';

/// 「今日のひとこと」を表示する共通カード（最大幅480）
class TodaySummaryCard extends StatelessWidget {
  final String summary;
  const TodaySummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final width = MediaQuery.of(context).size.width;
    final double maxWidth = width <= 0 ? 480 : (width - 40).clamp(280, 480);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth.toDouble()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今日のひとこと',
              style: textTheme.labelLarge?.copyWith(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              summary,
              style: textTheme.bodyMedium?.copyWith(color: AppTheme.textDark),
            ),
          ],
        ),
      ),
    );
  }
}
