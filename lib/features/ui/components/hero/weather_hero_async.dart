import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clothes_app/features/ui/components/hero/weather_hero.dart';
import 'package:clothes_app/features/ui/components/cards/today_summary_card.dart';

class WeatherHeroAsync extends StatelessWidget {
  final AsyncValue<dynamic> weatherAsync;
  final AsyncValue<dynamic> clothesAsync;

  const WeatherHeroAsync({
    super.key,
    required this.weatherAsync,
    required this.clothesAsync,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return weatherAsync.when(
      data: (w) {
        // フッターは clothes の状態に応じて用意
        final Widget? footer = clothesAsync.when(
          data: (c) {
            final summary = c.summary as String?;
            if (summary == null || summary.isEmpty) return null;
            return TodaySummaryCard(summary: summary);
          },
          loading: () => const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (_, __) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '服装データを取得できませんでした',
                style: textTheme.bodyMedium?.copyWith(color: Colors.black87),
              ),
            ),
          ),
        );

        return WeatherHero(
          condition: w.condition ?? '',
          temperature: w.value ?? 0,
          feelsLike: w.feelsLike ?? 0,
          region: w.region ?? '',
          footer: footer,
        );
      },
      loading: () => const SizedBox(
        height: 160,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      ),
      error: (_, __) => Text(
        '天気を取得できません',
        style: textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
    );
  }
}
