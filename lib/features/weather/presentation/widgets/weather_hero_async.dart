import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clothes_app/features/weather/presentation/widgets/weather_hero.dart';
import 'package:clothes_app/core/widgets/today_summary_card.dart';
import 'package:clothes_app/features/weather/domain/entities/weather.dart';
import 'package:clothes_app/features/clothes/domain/entities/clothes_suggestion.dart';

class WeatherHeroAsync extends StatelessWidget {
  final AsyncValue<TodayWeather> weatherAsync;
  final AsyncValue<ClothesSuggestion> clothesAsync;

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
            final summary = c.summary;
            if (summary.isEmpty) return null;
            return TodaySummaryCard(summary: summary);
          },
          loading: () => const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (err, st) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
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
          condition: w.condition,
          temperature: w.value,
          feelsLike: w.feelsLike,
          region: w.region,
          footer: footer,
        );
      },
      loading: () => const SizedBox(
        height: 160,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      ),
      error: (err, st) => Text(
        '天気を取得できません',
        style: textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
    );
  }
}
