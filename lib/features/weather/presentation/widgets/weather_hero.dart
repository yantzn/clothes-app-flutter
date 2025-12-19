import 'package:flutter/material.dart';
import 'package:clothes_app/features/weather/presentation/widgets/weather_icon.dart';

class WeatherHero extends StatelessWidget {
  final String condition;
  final num temperature;
  final num feelsLike;
  final String region;
  final Widget? footer; // 下部に任意のコンテンツ（例: 今日のひとこと or ローディングなど）
  final LinearGradient Function(String condition)? gradientBuilder;

  const WeatherHero({
    super.key,
    required this.condition,
    required this.temperature,
    required this.feelsLike,
    required this.region,
    this.footer,
    this.gradientBuilder,
  });

  LinearGradient _defaultGradient(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('rain') || c.contains('雨')) {
      return const LinearGradient(
        colors: [Color(0xFF6C8DDC), Color(0xFFB3C9FF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (c.contains('cloud') || c.contains('曇') || c.contains('くもり')) {
      return const LinearGradient(
        colors: [Color(0xFF9FB3D9), Color(0xFFD7E3F5)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (c.contains('snow') || c.contains('雪')) {
      return const LinearGradient(
        colors: [Color(0xFFE3F2FD), Color(0xFFB3E5FC)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFF7EC8FF), Color(0xFFE3F4FF)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final gradient = (gradientBuilder ?? _defaultGradient).call(condition);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 13, 20, 32),
      decoration: BoxDecoration(gradient: gradient),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          WeatherIcon(condition: condition, size: 96, color: Colors.white),
          const SizedBox.shrink(),
          Text(
            '${temperature.toStringAsFixed(0)}°',
            style: textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              height: 0.9,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '体感 ${feelsLike.toStringAsFixed(0)}°',
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.place_outlined, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                region,
                style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ],
          ),
          if (footer != null) ...[const SizedBox(height: 24), footer!],
        ],
      ),
    );
  }
}
